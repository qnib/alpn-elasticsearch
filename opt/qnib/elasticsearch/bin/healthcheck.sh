#!/bin/bash

echoerr() { echo "$@" 1>&2; }

CHECK_URL=http://127.0.0.1:9200
echo "curl -sI ${CHECK_URL}"
curl -sI ${CHECK_URL}
if [ $? -ne 0 ];then
  echoerr "'curl -sI ${CHECK_URL}' failed..."
  exit 1
fi
STATUS=$(curl -s "${CHECK_URL}/_cat/health?h=status")
if [ $? -ne 0 ];then
  echoerr "'curl -sI ${CHECK_URL}/_cat/health?h=status' failed..."
  exit 1
fi

if [ ${STATUS} = "green" ];then
  echo "Cluster is green, all fine..."
  exit 0
elif [ ${STATUS} = "red" ];then
  echoerr "Cluster is red!... "
  exit 1
elif [ ! -f /tmp/es_initialised ] && [ ${STATUS} = "yellow" ];then
  echoerr "Node has not initialised, and cluster is yellow -> considered an error..."
  exit 1
elif [ ${STATUS} = "yellow" ];then
  echo "Cluster is yellow but we are already over the initialisation phase and assume someone else was updated."
  exit 0
else
  echoerr "Cluster is neither green,yello or red, but '${STATUS}'"
  exit 1
fi
