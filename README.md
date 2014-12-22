##Deploy Periscope

### Get the repository

In order to deploy Periscope locally using Docker you'll need to clone this repository: 

```git clone https://github.com/sequenceiq/docker-periscope.git```

The repo contains a bunch of shell scripts for remote and local deployments as well. 

### Host the full stack

If you want to host the full stack (Postgres, UAA, Periscope) use the scripts found in the `local` directory. All you have to do is to fill out the `env_props.sh.sample` file and rename it to `env_props.sh`. These are the SMTP settings which are used by Periscope to send notifications. 

`Note: if you are using bare metal without Cloudbreak for deployments you can leave the PERISCOPE_CLOUDBREAK_URL as it is.` 

After the `env_props.sh` configuration is ready simply launch the `start_periscope.sh` and it will do everything automatically for you. What's this shell script is doing:

* It pulls the sequenceiq/periscope, sequenceiq/uaa and the postgres Docker images from Docker registry.
* Since Periscope is using OAuth2 for security we'll need an UAA server and a DB for the user management. The script will launch these 2 components in a Docker container so you don't have to deal with this. We are using `Cloudfoundry's` UAA server. Obviously if you are already hosting a ResourceServer you can use that one as well. For reference you can find the UAA Dockerfile and configuration [here](https://github.com/sequenceiq/docker-uaa). We pre-configured a default user, but you can change it anyway you want, default settings are: username: `admin@sequenceiq.com` password: `seqadmin`.
* After the UAA is up and running it will launch a postgres Docker container for storing the `Clusters` `Alarms` and `Scaling policies`.
* Will Periscope itself and connect to the previously launched postgres DB and UAA server.

The result will be 4 running Docker containers and you can see Periscope's log at the end: `docker logs -f periscope`.

### Adding an Ambari managed Hadoop cluster

Periscope is integrated with [Uluwatu](https://github.com/sequenceiq/uluwatu) as the UI, but if you are not using Cloudbreak you still can use the pure REST API. There are lots of `curl` samples available [here](https://github.com/sequenceiq/periscope/blob/master/src/main/resources/curl-samples.sh), just a quick example how to add a cluster and a metric alarm:

```
UAA_ADDR=$(docker inspect -f "{{.NetworkSettings.IPAddress}}" uaa)
UAA=http://$UAA_ADDR:8080
PERI_ADDR=$(docker inspect -f "{{.NetworkSettings.IPAddress}}" periscope)
HOST=$PERI_ADDR:8080

TOKEN=$(curl -iX POST -H "accept: application/x-www-form-urlencoded" -d 'credentials={"username":"admin@sequenceiq.com","password":"seqadmin"}' "$UAA/oauth/authorize?response_type=token&client_id=periscope-client&scope.0=openid&source=login&redirect_uri=http://periscope.client"  | grep Location | cut -d'=' -f 2 | cut -d'&' -f 1)

curl -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"host":"<AMBARI_IP>", "port":"8080", "user":"admin", "pass":"admin"}' $HOST/clusters

curl -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"alarmName":"freeGlobalResourcesRateLow","description":"Low free global resource rate","metric":"GLOBAL_RESOURCES","threshold":0.4,"comparisonOperator":"LESS_THAN","period":1,"notifications":[{"target":["some1@sequenceiq.com"],"notificationType":"EMAIL"}]}' $HOST/clusters/50/alarms/metric

curl -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"name":"upScale","adjustmentType":"NODE_COUNT","scalingAdjustment":2,"hostGroup":"slave_1","alarmId":"150"}' $HOST/clusters/50/policies
```
