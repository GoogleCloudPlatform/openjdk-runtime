# Test Application

This is a test application to be used in testing the Java Runtimes containers. It implements a set
of http endpoints which exercise integrations with various Stackdriver APIs, in line with the 
[Runtimes-common integration test framework](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/integration_tests#tests).

The test application is a simple [Spring Boot](https://projects.spring.io/spring-boot/) application,
which can be built in several different ways.

## Supported profiles
- **Integration test profile** - stages the application for use in the [runtimes-common integration testing framework](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/integration_tests).
Invoke with: 
```bash
mvn install -Pint-test
```
- **Deploy check profile** - stages the application for deployment directly to App Engine.
Invoke with: 
```bash
mvn install -Pdeployment-test
```

## Supported packaging types
The test application can be packaged using variable packaging types. Select among them using the
`packaging.type` maven property. These can be mixed with the various profiles above. Supported packaging types:
- `mvn install -Dpackaging.type=jar`
- `mvn install -Dpackaging.type=war`


