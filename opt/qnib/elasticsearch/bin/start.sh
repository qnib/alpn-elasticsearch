#!/usr/local/bin/dumb-init /bin/bash
set -ex

function wait_es {
    # wait for es to come up
    if [ $(curl -s localhost:9200|grep status|grep -c 200) -ne 1 ];then
        sleep 1
        wait_es
    else
        echo "$(date +'%F %H:%M:%S') > Elasticsearch return status 200 -> good to go"
    fi
}

if [ "X${ES_TAGS}" != "X" ];then
   TAGS=$(python -c 'import os;print "\",\"".join(os.environ["ES_TAGS"].split(","))')
   sed -i'' -e "s/\"tags\":.*/\"tags\": [\"${TAGS}\"],/" /etc/consul.d/elasticsearch.json
   consul reload
fi

if [ ! -z ${ES_RAMDISK_SIZE} ];then
    mkdir -p ${ES_PATH_DATA}
    mount -t tmpfs -o size=${ES_RAMDISK_SIZE} tmpfs ${ES_PATH_DATA}
fi

if [ "X${ES_PUB_IP}" == "X" ];then
    export ES_PUB_IP=$(ip -o -4 add|egrep '16|24' |head -n1 |egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
fi

if [ -z ${ES_NODE_NAME} ] && [ -f /etc/hostname ];then
  export ES_NODE_NAME=$(cat /etc/hostname)
fi
consul-template -once -template "/etc/consul-templates/elasticsearch/elasticsearch.json.ctmpl:/etc/consul.d/elasticsearch.json"
consul reload
sleep 5
consul-template -once -template "/etc/consul-templates/elasticsearch/logging.yml.ctmpl:/opt/elasticsearch/config/logging.yml"
consul-template -consul localhost:8500 -once -template "/etc/consul-templates/elasticsearch/elasticsearch.yml.ctmpl:/opt/elasticsearch/config/elasticsearch.yml"
mkdir -p /opt/elasticsearch/data /opt/elasticsearch/logs
chown -R elasticsearch: /opt/elasticsearch/data /opt/elasticsearch/logs
su -c '/opt/elasticsearch/bin/elasticsearch' elasticsearch

exit 0
