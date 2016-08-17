#!/bin/bash
set -ex

CHECK_URL=http://127.0.0.1:9200
echo "curl -sI ${CHECK_URL}"
curl -sI ${CHECK_URL}
echo "curl -s "${CHECK_URL}/_cat/health?h=status" | grep -E 'green|yellow'"
curl -s "${CHECK_URL}/_cat/health?h=status" | grep -E 'green|yellow'
