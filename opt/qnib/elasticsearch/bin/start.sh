#!/usr/local/bin/dumb-init /bin/bash

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
   sed -i'' -e "s/\"tags\":.*/\"tags\": [\"${TAGS}\"],/" /etc/consul.d/check_elasticsearch.json
   consul reload
fi


sed -i'' -e "s/ES_NODE_NAME/${ES_NODE_NAME-$(hostname)}/" /etc/elasticsearch/elasticsearch.yml
sed -i'' -e "s/ES_DATA_NODE/${ES_DATA_NODE-true}/" /etc/elasticsearch/elasticsearch.yml
sed -i'' -e "s/ES_MASTER_NODE/${ES_MASTER_NODE-true}/" /etc/elasticsearch/elasticsearch.yml
sed -i'' -e "s/ES_CLUSTER_NAME/${ES_CLUSTER_NAME-qnib}/" /etc/elasticsearch/elasticsearch.yml

/usr/share/elasticsearch/bin/elasticsearch -p /var/run/elasticsearch/elasticsearch.pid \
    -Des.default.path.home=/usr/share/elasticsearch \
    -Des.default.path.logs=/var/log/elasticsearch \
    -Des.default.path.data=/var/lib/elasticsearch \
    -Des.default.path.work=/tmp/elasticsearch \
    -Des.default.path.conf=/etc/elasticsearch &

sleep 10
wait_es

if [ "X${ES_IDX}" != "X" ];then
    echo "$(date +'%F %H:%M:%S') > Deleting index ${ES_IDX}"
    curl -XDELETE "http://localhost:9200/${ES_IDX}"
    echo '\n PUT index settings.'
    if [ -f /opt/qnib/etc/${ES_IDX}/settings.json ];then
        curl -XPUT "http://localhost:9200/${ES_IDX}/" --data-binary @/opt/qnib/etc/${ES_IDX}/settings.json
    else
        curl -XPUT "http://localhost:9200/${ES_IDX}/"
    fi
    echo '\n'
    if [ -f /opt/qnib/etc/${ES_IDX}/mappings.json ];then
        echo ' Add mappings'
        curl -XPUT "http://localhost:9200/${ES_IDX}/_mappings" --data-binary @/opt/qnib/etc/${ES_IDX}/mappings.json
        echo '\n'
    fi

fi

su -c '/opt/elasticsearch/bin/elasticsearch' elasticsearch
