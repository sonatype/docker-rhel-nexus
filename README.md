# sonatype/docker-rhel-nexus [![Build Status](https://travis-ci.org/sonatype/docker-rhel-nexus.svg?branch=master)](https://travis-ci.org/sonatype/docker-rhel-nexus)

Dockerfile for Sonatype Nexus Repository Manager 3 with OpenJDK and
Red Hat Enterprise Linux 7. Made to run on the Red Hat OpenShift Container
Platform.

Looking for Nexus 2? Checkout the [Nexus 2 branch](https://github.com/sonatype/docker-rhel-nexus/tree/Nexus2). |
--- |

* [Docker](#docker)
  * [Notes](#notes)
  * [Persistent Data](#persistent-data)
* [OpenShift](#openshift)
  * [Building](#building)
  * [Quickstart](#quickstart)

# Docker

To (re)build the image:

```
$ docker build --rm=true --tag=sonatype/nexus3 .
```

To run, binding the exposed port 8081 to the host:

```
$ docker run -d -p 8081:8081 --name nexus sonatype/nexus3
```

To confirm the Nexus server is running on port 8081:

```
$ curl -u admin:admin123 http://localhost:8081/service/metrics/ping
```

## Notes

* Default credentials are: `admin` / `admin123`

* It can take some time (2-3 minutes) for the service to launch in a
new container.  You can tail the log to determine once Nexus is ready:

```
$ docker logs -f nexus
```

* Installation of Nexus is to `/opt/sonatype/nexus`.  

* A persistent directory, `/nexus-data`, is used for configuration,
logs, and storage. This directory needs to be writable by the Nexus
process, which runs as UID 200.

* Three environment variables can be used to control the JVM arguments

  * `JAVA_MAX_MEM`, passed as -Xmx.  Defaults to `1200m`.

  * `JAVA_MIN_MEM`, passed as -Xms.  Defaults to `1200m`.

  * `EXTRA_JAVA_OPTS`.  Additional options can be passed to the JVM via
  this variable.

  These can be used supplied at runtime to control the JVM:

  ```
  $ docker run -d -p 8081:8081 --name nexus -e JAVA_MAX_HEAP=768m sonatype/nexus3
  ```


### Persistent Data

There are two general approaches to handling persistent storage requirements
with Docker. See [Managing Data in Containers](https://docs.docker.com/userguide/dockervolumes/)
for additional information.

  1. *Use a data volume*.  Since data volumes are persistent
  until no containers use them, a volume can be created specifically for 
  this purpose.  This is the recommended approach.  

  ```
  $ docker volume create --name nexus-data
  $ docker run -d -p 8081:8081 --name nexus -v nexus-data:/nexus-data sonatype/nexus3
  ```

  2. *Mount a host directory as the volume*.  This is not portable, as it
  relies on the directory existing with correct permissions on the host.
  However it can be useful in certain situations where this volume needs
  to be assigned to certain specific underlying storage.  

  ```
  $ mkdir /some/dir/nexus-data && chown -R 200 /some/dir/nexus-data
  $ docker run -d -p 8081:8081 --name nexus -v /some/dir/nexus-data:/nexus-data sonatype/nexus3
  ```

# OpenShift

## Building

First login in to OpenShift and clone the project and OpenShift branch

```
git clone https://github.com/sonatype/docker-rhel-nexus.git
```

## Quickstart

If you would like to run the init.sh script provided in the repository,
it will create an OpenShift project named `nexus` within your OpenShift
instance which has a pre-made template for Nexus 3.

```
cd docker-rhel-nexus/OpenShift/
./init.sh
```

After using the init.sh script, browse to the OpenShift console and login.
In the nexus project, click `Add to Project` and search for Nexus. Click
create and configure to create a Nexus service. Wait until the service has
been created and the deployment is successful. A Nexus instance should now
be available on the configured service.
