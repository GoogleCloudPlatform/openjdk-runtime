# Test Application

This is a test application to be used in testing the Java Runtimes containers. It implements a set
of http endpoints which exercise integrations with various Stackdriver APIs, in line with the 
[Runtimes-common integration test framework](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/integration_tests#tests).

The test application is a simple [Spring Boot](https://projects.spring.io/spring-boot/) application,
which can be built in several different ways.

## Supported profiles
**Custom runtime profile** - prepares files in the `target/deploy` directory for deployment to a custom runtime on App Engine Flexible:
  - When using this profile, the `app.deploy.image` property must be specified as well.
```bash
mvn install -Pruntime.custom -Dapp.deploy.image=gcr.io/google-appengine/openjdk
```
**Java runtime profile** - prepares files in the `target/deploy` directory for deployment to the default Java runtime on App Engine Flexible:
```bash
mvn install -Pruntime.java
```

## Supported packaging types
The test application can be packaged using variable packaging types. Select among them using the
`packaging.type` maven property. These can be mixed with the various profiles above. Supported packaging types:
- `mvn install -Dpackaging.type=jar`
- `mvn install -Dpackaging.type=war`


