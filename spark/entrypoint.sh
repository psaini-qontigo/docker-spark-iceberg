#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

start-master.sh -p 7077
start-worker.sh spark://spark-iceberg:7077
start-history-server.sh
start-thriftserver.sh  # --driver-java-options "-Dderby.system.home=/tmp/derby"

if [ -n "$WAIT_FOR" ]; then
  IFS=';' read -a HOSTPORT_ARRAY <<< "$WAIT_FOR"
  for HOSTPORT in "${HOSTPORT_ARRAY[@]}"
  do
    WAIT_FOR_HOST=${HOSTPORT%:*}
    WAIT_FOR_PORT=${HOSTPORT#*:}
      
    echo Waiting for $WAIT_FOR_HOST to listen on $WAIT_FOR_PORT...
    while ! nc -z $WAIT_FOR_HOST $WAIT_FOR_PORT; do echo sleeping; sleep 2; done
  done
fi

# Entrypoint, for example notebook, pyspark or spark-sql
if [[ $# -gt 0 ]] ; then
    eval "$1"
fi
