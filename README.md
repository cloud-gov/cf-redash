# Redash on cloud.gov

An example application showing how to deploy [Redash](https://redash.io/help/open-source/setup) to the cloud.gov platform.

<img src="https://raw.githubusercontent.com/getredash/website/8e820cd02c73a8ddf4f946a9d293c54fd3fb08b9/website/_assets/images/redash-anim.gif" width="80%"/>

## Overview

Redash runs in a Docker container, and requires 2 backing services to run on cloud.gov - a [Postgres database](https://cloud.gov/docs/services/relational-database/) and an instance of [Redis](https://cloud.gov/docs/services/aws-elasticache/). Background docs on running Docker apps on cloud.gov can be found [here](https://cloud.gov/docs/deployment/docker/). 

Since the [Redash image](https://hub.docker.com/r/redash/redash) exposes a non-standard port, it needs to be run on an [internal route](https://docs.cloudfoundry.org/devguide/deploy-apps/routes-domains.html#internal-routes) with an instance if nginx in front of it to proxy traffic from outside the cloud.gov platform. (Note - it's a good practice to run a proxy in front of Redash anyway, to restrict access to specific IP ranges, etc.)

This repo contains two applications - one to deploy the Redash Docker image to cloud.gov, and the other to deploy an nginx application to proxy traffic to it.

## Install steps

First, create the backing services for Redash (you can name these services whatever you want, just make sure to update the `app/vars.yml` file accordingly - see below):

```bash
~$ cf create-service aws-rds small-psql redash-database
```

```bash
~$ cf create-service aws-elasticache-redis redis-dev redash-redis
```

Note - it may take several minutes for these services to spin up. You can check the status of these services using `cf services`. When they are successfully created, you can do the initial push of the Redash image. 

In the `/app` directory, copy the file `vars.yml.example` to `vars.yml` and update the names of the two services you just created. Make any other changes to this file needed based on your usage scenario.

From inside the `/app` directory:

```bash
~$ cf push --no-start --vars-file vars.yml
```

Doing this will bind the backing services you just created to the Redash image you just pushed, but will not start the app until you have set the needed environmental variables. Run the following to get the connection details for the Postgres RDS and Elasticache Redis services.

```bash
~$ cf env {app-name}
```

Then, copy `setup-example.sh` to `setup.sh` and use the values found in the the `uri` attribute for these services in the `setup.sh` file. **Note, you will need to change the Redis uri to use `rediss://` rather than the `redis://` scheme returned when running `cf env`**. Once this is done, run the setup script and restage the app.

```bash
~$ ./setup.sh {app-name}
~$ cf restage {app-name}
```
When the app is pushed and restaged, change to the `/proxy` directory, and copy/update the `vars.yml` file as needed. Push the proxy app:

```bash
~$ cf push --vars-file vars.yml
```

The route for the proxy app is the public route you will use to access Redash. However, before your proxy can route traffic to Redash, you will need to set up a network policy for this.

```bash
~$ cf add-network-policy (proxy-app-name) {app-name} --port 5000 --protocol tcp
```

Once this is done, you should be able to access your Redash instance at the public `app.cloud.gov` route for your proxy application.

