FROM qnib/alpn-jre8

ENV ES_URL=https://download.elastic.co/elasticsearch/elasticsearch \
    ES_DATA_NODE=true \
    ES_MASTER_NODE=true \
    ES_HEAP_SIZE=512m \
    ES_NET_HOST=0.0.0.0 \
    ES_PATH_DATA=/opt/elasticsearch/data/ \
    ES_PATH_LOGS=/opt/elasticsearch/logs \
    ES_MLOCKALL=true
RUN apk add --update curl nmap jq vim \
 && rm -rf /var/cache/apk/* /tmp/* 
ADD etc/consul-templates/elasticsearch/elasticsearch.yml.ctmpl \
    etc/consul-templates/elasticsearch/logging.yml.ctmpl \
    etc/consul-templates/elasticsearch/elasticsearch.json.ctmpl \
    /etc/consul-templates/elasticsearch/
ADD opt/qnib/elasticsearch/bin/start.sh \
    opt/qnib/elasticsearch/bin/stop.sh \
    /opt/qnib/elasticsearch/bin/
ADD etc/supervisord.d/elasticsearch.ini /etc/supervisord.d/
RUN apk add --update python git bc \
 && curl -sLo /opt/es-backup-scripts.zip https://github.com/import-io/es-backup-scripts/archive/master.zip \
 && unzip -q -d /opt/ /opt/es-backup-scripts.zip \
 && rm -f /opt/es-backup-scripts.zip \
 && mv /opt/es-backup-scripts-master/ /opt/es-backup-scripts \
 && apk del git \
 && rm -rf /var/cache/apk/* /tmp/* 
ENV ES_VER=1.7.5 
RUN curl -sL ${ES_URL}/elasticsearch-${ES_VER}.tar.gz |tar xfz - -C /opt/ \
 && mv /opt/elasticsearch-${ES_VER} /opt/elasticsearch 
VOLUME ["/opt/elasticsearch/logs", "/opt/elasticsearch/data/"]
RUN adduser -s /bin/bash -u 2000 -h /opt/elasticsearch -H -D elasticsearch \
 && echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/jdk/bin" >> /opt/elasticsearch/.bash_profile \
 && chown -R elasticsearch: /opt/elasticsearch 
