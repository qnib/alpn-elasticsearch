#!/usr/local/bin/dumb-init /bin/bash
set -x

source /opt/qnib/consul/etc/bash_functions.sh

wait_for_srv elasticsearch 

set -e

##### Register index templates #####
for x in $(find /opt/qnib/elasticsearch/index-registration/mappings/ -type f -name "*.json");do
    IDX=$(echo ${x} |awk -F/ '{print $NF}' |awk -F. '{print $1}')
    curl -sXPUT "http://127.0.0.1:9200/_template/${IDX}" --data-binary @${x}
done

exit 0
