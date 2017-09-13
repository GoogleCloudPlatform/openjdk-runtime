# Test Application

This is a test application to be used in testing the Java Runtimes containers. It implements a set
of http endpoints which exercise integrations with various Stackdriver APIs, in line with the 
[Runtimes-common integration test framework](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/integration_tests#tests).

The test application is a simple [Spring Boot](https://projects.spring.io/spring-boot/) application,
which can be built in several different ways.

## Supported profiles
### Runtime staging profiles
Runtime staging profiles can be mixed & matched with deployment profiles.

**Java runtime profile (default)** - prepares files in the `target/deploy` directory for deployment to the default Java runtime on App Engine Flexible:
```bash
mvn install -Pruntime.java
```
**Custom runtime profile** - prepares files in the `target/deploy` directory for deployment to a custom runtime on App Engine Flexible:
  - When using this profile, the `app.deploy.image` property must be specified as well.
```bash
mvn install -Pruntime.custom -Dapp.deploy.image=gcr.io/google-appengine/openjdk
```

### Deployment profiles
Deployment profiles can be mixed & matched with runtime staging profiles.

**JAR deployment profile (default)** - packages the application as an executable JAR that embeds a web server.
```bash
mvn install -Pdeploy.jar
```
**WAR deployment profile** - packages the application as a WAR file that can be deployed to a web server instance.
```bash
mvn install -Pdeploy.war
```


