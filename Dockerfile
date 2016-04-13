FROM qnib/alpn-jre8

ENV ES_VER=2.3.1 \
    ES_URL=https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch
RUN apk add --update curl \
 && curl -sL ${ES_URL}/${ES_VER}/elasticsearch-${ES_VER}.tar.gz |tar xfz - -C /opt/ \
 && mv /opt/elasticsearch-${ES_VER} /opt/elasticsearch \
 && rm -rf /var/cache/apk/* /tmp/* 
RUN adduser -s /bin/bash -u 2000 -h /opt/elasticsearch -H -D elasticsearch \
 && echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/jdk/bin" >> /opt/elasticsearch/.bash_profile \
 && chown -R elasticsearch: /opt/elasticsearch 
ADD opt/qnib/elasticsearch/bin/start.sh \
    opt/qnib/elasticsearch/bin/stop.sh \
    /opt/qnib/elasticsearch/bin/
ADD etc/supervisord.d/elasticsearch.ini /etc/supervisord.d/
ADD etc/consul.d/elasticsearch.json /etc/consul.d/
