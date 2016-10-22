# alpn-elasticsearch

Alpine image holding elasticsearch

**Please note**: Each ES container consumes 2GB of memory, so please make sure you have enough on the docker host. :)

## startup

First start the consul server so that all the other containers have something to look forward to.

```
$ docker-compose up -d consul
Creating network "alpnelasticsearch_default" with the default driver
Creating es-consul
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                     NAMES
4878774546b8        qnib/alpn-consul    "/opt/qnib/supervisor"   4 seconds ago       Up 3 seconds        0.0.0.0:32774->8500/tcp   es-consul
$ 
```

Afterwards start the rest:

```
$ docker-compose up -d
es-consul is up-to-date
Creating alpnelasticsearch_esd_1
Creating esm
$ 
```

Afterwards enjoy your little cluster.

```
$ curl -s "http://localhost$(docker port esm |egrep -o ':.*$')/_cluster/health" |jq .
{
  "cluster_name": "qnib",
  "status": "green",
  "timed_out": false,
  "number_of_nodes": 2,
  "number_of_data_nodes": 1,
  "active_primary_shards": 0,
  "active_shards": 0,
  "relocating_shards": 0,
  "initializing_shards": 0,
  "unassigned_shards": 0,
  "delayed_unassigned_shards": 0,
  "number_of_pending_tasks": 0,
  "number_of_in_flight_fetch": 0,
  "task_max_waiting_in_queue_millis": 0,
  "active_shards_percent_as_number": 100
}
```

Or open it in a browser:

```
$ open "http://localhost$(docker port esm |egrep -o ':.*$')/_cluster/health"
```

## Scaling

You can scale the data-nodes up and down with the docker-compose command:

```
$ docker-compose scale esd=2
Creating and starting alpnelasticsearch_esd_2 ... done
$ sleep 30 
$ docker ps
CONTAINER ID        IMAGE                           COMMAND                  CREATED              STATUS                        PORTS                     NAMES
f22439ee4151        qnib/alpn-elasticsearch:5.0.0   "/opt/qnib/supervisor"   About a minute ago   Up About a minute (healthy)                             alpnelasticsearch_esd_2
76c0e5cd6bb9        qnib/alpn-elasticsearch:5.0.0   "/opt/qnib/supervisor"   About a minute ago   Up About a minute (healthy)   0.0.0.0:32769->9200/tcp   esm
8a39cae21ab8        qnib/alpn-elasticsearch:5.0.0   "/opt/qnib/supervisor"   About a minute ago   Up About a minute (healthy)                             alpnelasticsearch_esd_1
4f88367ff159        qnib/alpn-consul                "/opt/qnib/supervisor"   About a minute ago   Up About a minute             0.0.0.0:32768->8500/tcp   es-consul
$ curl -s "http://localhost$(docker port esm |egrep -o ':.*$')/_cluster/health" |jq .
{
  "cluster_name": "qnib",
  "status": "green",
  "timed_out": false,
  "number_of_nodes": 3,
  "number_of_data_nodes": 2,
  "active_primary_shards": 0,
  "active_shards": 0,
  "relocating_shards": 0,
  "initializing_shards": 0,
  "unassigned_shards": 0,
  "delayed_unassigned_shards": 0,
  "number_of_pending_tasks": 0,
  "number_of_in_flight_fetch": 0,
  "task_max_waiting_in_queue_millis": 0,
  "active_shards_percent_as_number": 100
}
```

