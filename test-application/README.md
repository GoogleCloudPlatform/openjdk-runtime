# Test Application

This is a test application to be used by the [runtimes-common integration testing framework](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/integration_tests).  It implements a set of http endpoints which exercise integrations with various Stackdriver APIs. The set of required endpoints is specified [here](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/integration_tests#tests).

The test application is a simple [Spring Boot](https://projects.spring.io/spring-boot/) application, which is packaged as a fat jar, for deployment to the openjdk runtime.
