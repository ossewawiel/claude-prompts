# Kotlin Spring Boot Resources - Claude Code Instructions

## CONTEXT
- **Project Type**: reference
- **Complexity**: simple
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Official Documentation
- **Spring Boot with Kotlin**: https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started.html#getting-started.first-application.code.kotlin
- **Spring Framework Kotlin Support**: https://docs.spring.io/spring-framework/docs/current/reference/html/languages.html#kotlin
- **Spring Boot Kotlin Tutorial**: https://spring.io/guides/tutorials/spring-boot-kotlin/
- **Kotlin Spring DSL**: https://docs.spring.io/spring-framework/docs/current/kdoc-api/spring-framework/
- **Spring Boot Gradle Plugin**: https://docs.spring.io/spring-boot/docs/current/gradle-plugin/reference/htmlsingle/

### Kotlin-Specific Features
- **Kotlin Extensions for Spring**: https://docs.spring.io/spring-framework/docs/current/reference/html/languages.html#kotlin-extensions
- **Kotlin Coroutines with Spring**: https://docs.spring.io/spring-framework/docs/current/reference/html/languages.html#coroutines
- **Kotlin Null Safety**: https://kotlinlang.org/docs/null-safety.html
- **Kotlin Data Classes**: https://kotlinlang.org/docs/data-classes.html
- **Kotlin DSL for Gradle**: https://docs.gradle.org/current/userguide/kotlin_dsl.html

## IMPLEMENTATION STRATEGY

### Spring Boot Starters
- **Web Starter**: `spring-boot-starter-web`
- **Data JPA Starter**: `spring-boot-starter-data-jpa`
- **Security Starter**: `spring-boot-starter-security`
- **Test Starter**: `spring-boot-starter-test`
- **Validation Starter**: `spring-boot-starter-validation`
- **Actuator Starter**: `spring-boot-starter-actuator`

### Project Setup Resources
- **Spring Initializr**: https://start.spring.io/
- **Kotlin Spring Boot Template**: https://github.com/spring-guides/gs-spring-boot-kotlin
- **Sample Projects**: https://github.com/spring-projects/spring-boot/tree/main/spring-boot-samples
- **Spring Boot CLI**: https://docs.spring.io/spring-boot/docs/current/reference/html/cli.html

### Configuration Patterns
```kotlin
// application.yml configuration
# https://docs.spring.io/spring-boot/docs/current/reference/html/application-properties.html

// @ConfigurationProperties
# https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config.typesafe-configuration-properties

// Environment-specific configs
# https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.profiles
```

### Database Integration
- **Spring Data JPA**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/
- **Spring Data JPA with Kotlin**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/#kotlin
- **JPA Entity with Kotlin**: https://spring.io/guides/tutorials/spring-boot-kotlin/#_persistence_with_jpa
- **Repository Patterns**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/#repositories

### Security Resources
- **Spring Security with Kotlin**: https://docs.spring.io/spring-security/reference/kotlin.html
- **JWT Authentication**: https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/jwt.html
- **Method Security**: https://docs.spring.io/spring-security/reference/servlet/authorization/method-security.html
- **CORS Configuration**: https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#mvc-cors

### Testing Resources
- **Spring Boot Testing**: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing
- **MockK for Kotlin**: https://mockk.io/
- **Testcontainers**: https://testcontainers.com/guides/testing-spring-boot-rest-api-using-testcontainers/
- **WireMock**: https://wiremock.org/docs/spring-boot/

### Performance & Monitoring
- **Spring Boot Actuator**: https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html
- **Micrometer Metrics**: https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.metrics
- **Spring Boot Admin**: https://codecentric.github.io/spring-boot-admin/current/
- **Application Properties**: https://docs.spring.io/spring-boot/docs/current/reference/html/application-properties.html

### Build & Deployment
- **Gradle Kotlin DSL**: https://docs.gradle.org/current/userguide/kotlin_dsl.html
- **Spring Boot Gradle Plugin**: https://docs.spring.io/spring-boot/docs/current/gradle-plugin/reference/htmlsingle/
- **Docker with Spring Boot**: https://spring.io/guides/topicals/spring-boot-docker/
- **Kubernetes Deployment**: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

### Development Tools
- **IntelliJ IDEA Kotlin**: https://www.jetbrains.com/help/idea/kotlin.html
- **Spring Boot DevTools**: https://docs.spring.io/spring-boot/docs/current/reference/html/using.html#using.devtools
- **Kotlin REPL**: https://kotlinlang.org/docs/command-line.html#run-the-repl
- **Spring Boot CLI**: https://docs.spring.io/spring-boot/docs/current/reference/html/cli.html

### Code Quality
- **ktlint**: https://ktlint.github.io/
- **Detekt**: https://detekt.dev/
- **SonarQube Kotlin**: https://docs.sonarqube.org/latest/analysis/languages/kotlin/
- **Kotlin Coding Conventions**: https://kotlinlang.org/docs/coding-conventions.html

### Community Resources
- **Spring Community**: https://spring.io/community
- **Kotlin Slack**: https://surveys.jetbrains.com/s3/kotlin-slack-sign-up
- **Spring Boot GitHub**: https://github.com/spring-projects/spring-boot
- **Kotlin GitHub**: https://github.com/JetBrains/kotlin
- **Awesome Kotlin**: https://github.com/KotlinBy/awesome-kotlin

### Tutorials & Guides
- **Building REST APIs**: https://spring.io/guides/tutorials/rest/
- **Securing a Web Application**: https://spring.io/guides/gs/securing-web/
- **Accessing Data with JPA**: https://spring.io/guides/gs/accessing-data-jpa/
- **Building a RESTful Web Service**: https://spring.io/guides/gs/rest-service/
- **Consuming REST Services**: https://spring.io/guides/gs/consuming-rest/

### Advanced Topics
- **Reactive Programming**: https://docs.spring.io/spring-framework/docs/current/reference/html/web-reactive.html
- **WebFlux with Kotlin**: https://docs.spring.io/spring-framework/docs/current/reference/html/languages.html#kotlin-web
- **Kotlin Coroutines**: https://docs.spring.io/spring-framework/docs/current/reference/html/languages.html#coroutines
- **Spring Cloud**: https://spring.io/projects/spring-cloud
- **Microservices with Spring Boot**: https://spring.io/microservices

### Migration Resources
- **Java to Kotlin Migration**: https://kotlinlang.org/docs/mixing-java-kotlin-intellij.html
- **Spring Boot Migration Guide**: https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide
- **Kotlin Migration Tools**: https://kotlinlang.org/docs/code-analysis.html

### Books & Publications
- **Spring Boot in Action**: Manning Publications
- **Kotlin in Action**: Manning Publications
- **Spring Security in Action**: Manning Publications
- **Spring Boot: Up and Running**: O'Reilly Media

### Video Resources
- **Spring Boot YouTube**: https://www.youtube.com/c/SpringSourceDev
- **Kotlin by JetBrains**: https://www.youtube.com/c/Kotlin
- **Spring Boot Tutorials**: https://www.youtube.com/results?search_query=spring+boot+kotlin+tutorial

### Sample Projects & Examples
- **Spring Boot Kotlin Examples**: https://github.com/spring-guides/gs-spring-boot-kotlin
- **Petclinic Kotlin**: https://github.com/spring-petclinic/spring-petclinic-kotlin
- **Real World Example**: https://github.com/gothinkster/kotlin-spring-realworld-example-app
- **Microservices Example**: https://github.com/microservices-patterns/ftgo-application-kotlin

### API Documentation
- **Swagger/OpenAPI**: https://springdoc.org/
- **Spring REST Docs**: https://docs.spring.io/spring-restdocs/docs/current/reference/html5/
- **API Versioning**: https://www.baeldung.com/rest-versioning

### Error Handling
- **Exception Handling**: https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#mvc-exceptionhandlers
- **Error Responses**: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.developing-web-applications.spring-mvc.error-handling
- **Validation**: https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#validation

## VALIDATION_CHECKLIST
- [ ] All documentation links verified and current
- [ ] Version compatibility confirmed
- [ ] Community resources actively maintained
- [ ] Official sources prioritized
- [ ] Kotlin-specific features highlighted
- [ ] Integration patterns documented
- [ ] Testing resources comprehensive
- [ ] Performance monitoring covered
- [ ] Security best practices included
- [ ] Migration paths provided