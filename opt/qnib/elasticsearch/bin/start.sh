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
   sed -i'' -e "s/\"tags\":.*/\"tags\": [\"${TAGS}\"],/" /etc/consul.d/elasticsearch.json
   consul reload
fi

consul-template -consul localhost:8500 -once -template "/etc/consul-templates/elasticsearch/elasticsearch.yml.ctmpl:/opt/elasticsearch/config/elasticsearch.yml"
consul-template -consul localhost:8500 -once -template "/etc/consul-templates/elasticsearch/logging.yml.ctmpl:/opt/elasticsearch/config/logging.yml"
chown -R elasticsearch: /opt/elasticsearch/data
su -c '/opt/elasticsearch/bin/elasticsearch' elasticsearch

exit 0
############### Never used part
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