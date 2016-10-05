# sonatype/openshift-nexus

Dockerfiles, templates and scripts for Sonatype Nexus Repository Manager 2 
with OpenJDK and Red Hat Enterprise Linux 7. Made to run on the Red Hat 
OpenShift Container Platform.

* [Docker](#docker)
  * [Notes](#notes)
  * [Persistent Data](#persistent-data)
  * [Adding Nexus Plugins](#adding-nexus-plugins)
* [OpenShift](#openshift)
  * [Building](#building)
  * [Quickstart](#quickstart)

# Docker

To (re)build the image:

```
# docker build --rm --tag sonatype/nexus-oss oss/
# docker build --rm --tag sonatype/nexus-pro pro/
```

To run, binding the exposed port 8081 to the host:

```
# docker run -d -p 8081:8081 --name nexus sonatype/nexus-pro
```

To determine the port that the container is listening on:

```
# docker ps -l
```

To confirm the Nexus server is running on port 8081:

```
$ curl http://localhost:8081/service/local/status
```

## Notes

* Default credentials are: `admin` / `admin123`

* It can take some time (2-3 minutes) for the service to launch in a
new container.  You can tail the log to determine once Nexus is ready:

```
$ docker logs -f nexus
```

* Installation of Nexus is to `/opt/sonatype/nexus`.  Notably:
  `/opt/sonatype/nexus/conf/nexus.properties` is the properties file.
  Parameters (`nexus-work` and `nexus-webapp-context-path`) defined
  here are overridden in the JVM invocation.

* A persistent directory, `/sonatype-work`, is used for configuration,
logs, and storage. This directory needs to be writeable by the Nexus
process, which runs as UID 200.

* Environment variables can be used to control the JVM arguments

  * `CONTEXT_PATH`, passed as -Dnexus-webapp-context-path.  This is used to define the
  URL which Nexus is accessed.  Defaults to '/nexus'
  * `MAX_HEAP`, passed as -Xmx.  Defaults to `768m`.
  * `MIN_HEAP`, passed as -Xms.  Defaults to `256m`.
  * `JAVA_OPTS`.  Additional options can be passed to the JVM via this variable.
  Default: `-server -XX:MaxPermSize=192m -Djava.net.preferIPv4Stack=true`.
  * `LAUNCHER_CONF`.  A list of configuration files supplied to the
  Nexus bootstrap launcher.  Default: `./conf/jetty.xml ./conf/jetty-requestlog.xml`

  These can be user supplied at runtime to control the JVM:

  ```
  $ docker run -d -p 8081:8081 --name nexus -e MAX_HEAP=768m sonatype/nexus
  ```


### Persistent Data

There are two general approaches to handling persistent
storage requirements with Docker. See [Managing Data in
Containers](https://docs.docker.com/userguide/dockervolumes/) for
additional information.

  1. *Use a data volume container*.  Since data volumes are persistent
  until no containers use them, a container can be created specifically for 
  this purpose.  This is the recommended approach.  

  ```
  $ docker run -d --name nexus-data sonatype/nexus echo "data-only container for Nexus"
  $ docker run -d -p 8081:8081 --name nexus --volumes-from nexus-data sonatype/nexus
  ```

  2. *Mount a host directory as the volume*.  This is not portable, as it
  relies on the directory existing with correct permissions on the host.
  However it can be useful in certain situations where this volume needs
  to be assigned to certain underlying storage.  

  ```
  $ mkdir /some/dir/nexus-data && chown -R 200 /some/dir/nexus-data
  $ docker run -d -p 8081:8081 --name nexus -v /some/dir/nexus-data:/sonatype-work sonatype/nexus
  ```


### Adding Nexus Plugins

Creating a docker image based on `sonatype/nexus` is the suggested
process: plugins should be expanded to `/opt/sonatype/nexus/nexus/WEB-INF/plugin-repository`.
See https://github.com/sonatype/docker-nexus/issues/9 for an example
concerning the Nexus P2 plugins.

# OpenShift

## Building

First login in to OpenShift and clone the project and OpenShift branch

```
git clone -b nexus2 https://github.com/sonatype/docker-rhel-nexus.git
```

## Quickstart

If you would like to run the init.sh script provided in the repository,
it will create an OpenShift project named `nexus` within your OpenShift
instance which has pre-made templates for either Nexus OSS and Nexus Pro.
The script takes a single argument for an `oss` or `pro` installation.

```
cd docker-rhel-nexus/OpenShift/
./init.sh pro
```

After using the init.sh script, browse to the OpenShift console and login.
In the nexus project, click `Add to Project` and search for Nexus. Click
create and configure to create a Nexus service. Wait until the service has
been created and the deployment is successful. A Nexus instance should now
be available on the configured service.
