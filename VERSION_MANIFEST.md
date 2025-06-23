### Template Interdependencies
```yaml
authentication_components:
  jwt-authentication.md:
    requires: []
    conflicts_with: []
    enhances:
      - "oauth2-integration.md"
      - "multi-factor-authentication.md"
    compatible_backends:
      - "spring-boot-kotlin-enterprise.md"
      - "node-express-rest-api.md"
      - "kotlin-ktor-microservice.md"
      - "cpp-beast-http-server.md"
  
  oauth2-integration.md:
    requires: 
      - "jwt-authentication.md >= 2.0.0"
    conflicts_with: []
    compatible_backends:
      - "spring-boot-kotlin-enterprise.md >= 1.4.0"
      - "spring-boot-java-microservice.md >= 2.0.0"
  
  multi-factor-authentication.md:
    requires:
      - "jwt-authentication.md >= 2.1.0"
    conflicts_with: []

kotlin_ecosystem:
  spring-boot-kotlin-enterprise.md:
    requires: []
    enhances:
      - "vaadin-spring-boot-fullstack.md"
      - "kotlin-android-native.md"
    compatible_frontends:
      - "react-typescript-spa.md"
      - "vaadin-spring-boot-fullstack.md"
    compatible_mobile:
      - "kotlin-android-native.md"
      - "kotlin-multiplatform-mobile.md"
  
  kotlin-multiplatform-mobile.md:
    requires: []
    enhances:
      - "kotlin-ktor-microservice.md"
      - "spring-boot-kotlin-enterprise.md"
    shared_backend:
      - "kotlin-ktor-microservice.md >= 1.3.0"

vaadin_ecosystem:
  vaadin-spring-boot-fullstack.md:
    requires:
      - "spring-boot-kotlin-enterprise.md >= 1.5.0"
    conflicts_with:
      - "react-typescript-spa.md"
      - "vue-composition-stack.md"
    integrates_with:
      - "relational-database-setup.md"
      - "jwt-authentication.md"

android_ecosystem:
  kotlin-android-native.md:
    requires: []
    enhances:
      - "kotlin-multiplatform-mobile.md"
    compatible_backends:
      - "spring-boot-kotlin-enterprise.md"
      - "kotlin-ktor-microservice.md"
      - "node-express-rest-api.md"
  
  java-android-enterprise.md:
    requires: []
    conflicts_with:
      - "kotlin-android-native.md"
    compatible_backends:
      - "spring-boot-java-microservice.md"
      - "node-express-rest-api.md"

cpp_ecosystem:
  cpp-qt-desktop-app.md:
    requires: []
    conflicts_with: []
    compatible_backends:
      - "cpp-beast-http-server.md"
      - "cpp-crow-rest-api.md"
  
  cpp-beast-http-server.md:
    requires: []
    enhances:
      - "cpp-qt-desktop-app.md"
    compatible_frontends:
      - "react-typescript-spa.md"
      - "cpp-qt-desktop-app.md"

fullstack_combinations:
  react_node_postgresql:
    scenario: "react-typescript-spa.md >= 2.0.0"
    backend: "node-express-rest-api.md >= 2.0.0"
    database: "relational-database-setup.md >= 2.0.0"
    auth: "jwt-authentication.md >= 2.0.0"
    payment: "stripe-payment-integration.md >= 2.0.0"
    tested: "2025-06-18"
    status: "verified"
  
  kotlin_spring_vaadin_postgresql:
    scenario: "vaadin-spring-boot-fullstack.md >= 1.4.0"
    backend: "spring-boot-kotlin-enterprise.md >= 1.6.0"
    database: "relational-database-setup.md >= 2.1.0"
    auth: "jwt-authentication.md >= 2.2.0"
    tested: "2025-06-18"
    status: "verified"
  
  kotlin_android_spring_backend:
    mobile: "kotlin-android-native.md >= 2.2.0"
    backend: "spring-boot-kotlin-enterprise.md >= 1.6.0"
    database: "relational-database-setup.md >= 2.1.0"
    auth: "jwt-authentication.md >= 2.2.0"
    tested: "2025-06-17"
    status: "verified"# Claude Code Templates - Version Manifest

## DOCUMENT_OVERVIEW
**Purpose**: Central version tracking and compatibility matrix for all Claude Code templates
**Maintained By**: Template maintainers and community contributors  
**Update Frequency**: With every template change
**Last Updated**: 2025-06-18
**Manifest Version**: 1.0.0

## VERSIONING_SYSTEM

### Semantic Versioning Standard
All templates follow semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes to template structure or Claude Code compatibility
- **MINOR**: New features, sections, or significant improvements
- **PATCH**: Bug fixes, dependency updates, documentation improvements

### Version Format
```
Template Version: X.Y.Z
Compatible Claude Version: >= Claude-X.Y
Last Tested: YYYY-MM-DD
Status: [active|deprecated|archived]
```

## TEMPLATE_REGISTRY

### Scenarios (Complete Applications)
```yaml
web-applications:
  react-typescript-spa.md:
    version: "2.1.3"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-18"
    last_tested: "2025-06-15"
    status: "active"
    breaking_changes_since: "2.0.0"
    dependencies:
      - node: ">=20.0.0"
      - react: ">=18.3.0"
      - typescript: ">=5.5.0"
    
  react-nextjs-fullstack.md:
    version: "1.8.2"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-10"
    last_tested: "2025-06-10"
    status: "active"
    dependencies:
      - node: ">=20.0.0"
      - nextjs: ">=14.0.0"
    
  vue-nuxt-ecommerce.md:
    version: "1.5.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-05"
    last_tested: "2025-06-05"
    status: "active"
    dependencies:
      - node: ">=18.0.0"
      - vue: ">=3.4.0"
      - nuxt: ">=3.11.0"

  angular-enterprise-dashboard.md:
    version: "1.3.4"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-05-28"
    last_tested: "2025-05-28"
    status: "active"
    dependencies:
      - node: ">=18.0.0"
      - angular: ">=17.0.0"

backend-services:
  node-express-rest-api.md:
    version: "2.0.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-12"
    last_tested: "2025-06-12"
    status: "active"
    dependencies:
      - node: ">=20.0.0"
      - express: ">=4.19.0"
      - typescript: ">=5.5.0"
    
  spring-boot-kotlin-enterprise.md:
    version: "1.6.0"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-18"
    last_tested: "2025-06-18"
    status: "active"
    dependencies:
      - jdk: ">=21"
      - spring-boot: ">=3.3.0"
      - kotlin: ">=2.0.0"
      - gradle: ">=8.8"
    
  spring-boot-java-microservice.md:
    version: "2.1.4"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-16"
    last_tested: "2025-06-16"
    status: "active"
    dependencies:
      - jdk: ">=21"
      - spring-boot: ">=3.3.0"
      - maven: ">=3.9.0"
    
  spring-boot-kotlin-vaadin.md:
    version: "1.8.2"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-18"
    last_tested: "2025-06-18"
    status: "active"
    dependencies:
      - jdk: ">=21"
      - spring-boot: ">=3.3.0"
      - kotlin: ">=2.0.0"
      - vaadin: ">=24.4.0"
      - gradle: ">=8.8"
    
  kotlin-ktor-microservice.md:
    version: "1.4.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-14"
    last_tested: "2025-06-14"
    status: "active"
    dependencies:
      - jdk: ">=17"
      - kotlin: ">=2.0.0"
      - ktor: ">=2.3.11"
      - gradle: ">=8.8"
    
  quarkus-kotlin-native.md:
    version: "1.2.3"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-12"
    last_tested: "2025-06-12"
    status: "active"
    dependencies:
      - jdk: ">=21"
      - kotlin: ">=2.0.0"
      - quarkus: ">=3.11.0"
      - graalvm: ">=22.3.0"
    
  fastapi-python-async-api.md:
    version: "1.4.2"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-08"
    last_tested: "2025-06-08"
    status: "active"
    dependencies:
      - python: ">=3.12"
      - fastapi: ">=0.111.0"
    
  cpp-beast-http-server.md:
    version: "1.1.0"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-10"
    last_tested: "2025-06-10"
    status: "active"
    dependencies:
      - cpp: ">=20"
      - boost: ">=1.84.0"
      - cmake: ">=3.28.0"
    
  cpp-crow-rest-api.md:
    version: "1.0.2"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-08"
    last_tested: "2025-06-08"
    status: "active"
    dependencies:
      - cpp: ">=17"
      - crow: ">=1.0.0"
      - cmake: ">=3.20.0"

mobile-applications:
  react-native-cross-platform.md:
    version: "1.7.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-14"
    last_tested: "2025-06-14"
    status: "active"
    dependencies:
      - react-native: ">=0.74.0"
      - expo: ">=51.0.0"
    
  flutter-dart-mobile-app.md:
    version: "1.5.3"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-11"
    last_tested: "2025-06-11"
    status: "active"
    dependencies:
      - flutter: ">=3.22.0"
      - dart: ">=3.4.0"
    
  kotlin-android-native.md:
    version: "2.3.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-17"
    last_tested: "2025-06-17"
    status: "active"
    dependencies:
      - android-studio: ">=2024.1.1"
      - kotlin: ">=2.0.0"
      - gradle: ">=8.7"
      - android-gradle-plugin: ">=8.5.0"
      - compile-sdk: ">=34"
      - min-sdk: ">=24"
    
  kotlin-multiplatform-mobile.md:
    version: "1.9.0"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-15"
    last_tested: "2025-06-15"
    status: "active"
    dependencies:
      - kotlin: ">=2.0.0"
      - kotlin-multiplatform: ">=2.0.0"
      - android-studio: ">=2024.1.1"
      - xcode: ">=15.0"
    
  kotlin-compose-multiplatform.md:
    version: "1.6.2"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-13"
    last_tested: "2025-06-13"
    status: "active"
    dependencies:
      - kotlin: ">=2.0.0"
      - compose-multiplatform: ">=1.6.11"
      - gradle: ">=8.8"
    
  java-android-enterprise.md:
    version: "1.4.0"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-09"
    last_tested: "2025-06-09"
    status: "active"
    dependencies:
      - jdk: ">=17"
      - android-studio: ">=2024.1.1"
      - gradle: ">=8.7"
      - android-gradle-plugin: ">=8.5.0"

desktop-applications:
  electron-cross-platform.md:
    version: "2.0.3"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-12"
    last_tested: "2025-06-12"
    status: "active"
    dependencies:
      - node: ">=20.0.0"
      - electron: ">=31.0.0"
    
  tauri-rust-desktop.md:
    version: "1.3.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-10"
    last_tested: "2025-06-10"
    status: "active"
    dependencies:
      - rust: ">=1.79.0"
      - tauri: ">=1.7.0"
    
  javafx-kotlin-desktop.md:
    version: "1.7.4"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-16"
    last_tested: "2025-06-16"
    status: "active"
    dependencies:
      - jdk: ">=21"
      - kotlin: ">=2.0.0"
      - javafx: ">=22.0.1"
      - gradle: ">=8.8"
      - tornadofx: ">=2.0.0"
    
  java-swing-enterprise.md:
    version: "1.2.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-11"
    last_tested: "2025-06-11"
    status: "active"
    dependencies:
      - jdk: ">=21"
      - maven: ">=3.9.0"
      - miglayout: ">=11.3"
    
  cpp-qt-desktop-app.md:
    version: "1.5.0"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-14"
    last_tested: "2025-06-14"
    status: "active"
    dependencies:
      - cpp: ">=17"
      - qt: ">=6.7.0"
      - cmake: ">=3.28.0"
    
  cpp-gtkmm-linux-app.md:
    version: "1.1.2"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-08"
    last_tested: "2025-06-08"
    status: "active"
    dependencies:
      - cpp: ">=20"
      - gtkmm: ">=4.12.0"
      - cmake: ">=3.25.0"
```

### Components (Modular Features)
```yaml
authentication:
  jwt-authentication.md:
    version: "2.2.0"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-16"
    last_tested: "2025-06-16"
    status: "active"
    compatible_scenarios:
      - "react-typescript-spa.md >= 2.0.0"
      - "node-express-rest-api.md >= 1.8.0"
      - "spring-boot-kotlin-enterprise.md >= 1.4.0"
    
  oauth2-integration.md:
    version: "1.9.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-13"
    last_tested: "2025-06-13"
    status: "active"
    
  multi-factor-authentication.md:
    version: "1.2.0"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-09"
    last_tested: "2025-06-09"
    status: "active"

data-persistence:
  relational-database-setup.md:
    version: "2.1.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-17"
    last_tested: "2025-06-17"
    status: "active"
    supports_databases:
      - postgresql: ">=16.0"
      - mysql: ">=8.0"
      - sqlite: ">=3.45"
    
  caching-strategies.md:
    version: "1.6.2"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-14"
    last_tested: "2025-06-14"
    status: "active"

api-design:
  rest-api-standards.md:
    version: "2.0.3"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-15"
    last_tested: "2025-06-15"
    status: "active"
    
  graphql-schema-design.md:
    version: "1.4.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-07"
    last_tested: "2025-06-07"
    status: "active"
```

### Technology Stacks
```yaml
frontend:
  modern-react-stack.md:
    version: "3.0.0"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-18"
    last_tested: "2025-06-18"
    status: "active"
    includes_versions:
      - react: "18.3.1"
      - typescript: "5.5.x"
      - vite: "6.x"
      - tailwindcss: "3.4.x"
    
  vue-composition-stack.md:
    version: "2.1.2"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-12"
    last_tested: "2025-06-12"
    status: "active"

backend:
  node-enterprise-stack.md:
    version: "2.3.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-16"
    last_tested: "2025-06-16"
    status: "active"
    
  spring-boot-stack.md:
    version: "1.8.0"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-18"
    last_tested: "2025-06-18"
    status: "active"
    
  spring-boot-kotlin-stack.md:
    version: "2.2.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-18"
    last_tested: "2025-06-18"
    status: "active"
    includes_versions:
      - spring-boot: "3.3.x"
      - kotlin: "2.0.x"
      - gradle: "8.8.x"
      - postgresql: "16.x"
      - redis: "7.x"
    
  vaadin-enterprise-stack.md:
    version: "1.4.3"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-18"
    last_tested: "2025-06-18"
    status: "active"
    includes_versions:
      - vaadin: "24.4.x"
      - spring-boot: "3.3.x"
      - kotlin: "2.0.x"
      - postgresql: "16.x"
      - gradle: "8.8.x"
    
  java-enterprise-stack.md:
    version: "2.0.4"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-16"
    last_tested: "2025-06-16"
    status: "active"
    includes_versions:
      - jdk: "21"
      - spring-boot: "3.3.x"
      - maven: "3.9.x"
      - hibernate: "6.x"
      - junit: "5.x"
    
  kotlin-multiplatform-stack.md:
    version: "1.6.0"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-15"
    last_tested: "2025-06-15"
    status: "active"
    includes_versions:
      - kotlin: "2.0.x"
      - kotlin-multiplatform: "2.0.x"
      - ktor: "2.3.x"
      - serialization: "1.7.x"
    
  cpp-modern-stack.md:
    version: "1.3.2"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-12"
    last_tested: "2025-06-12"
    status: "active"
    includes_versions:
      - cpp: "20/23"
      - cmake: "3.28.x"
      - vcpkg: "2024.06.15"
      - boost: "1.84.x"
      - catch2: "3.6.x"
```

### Integrations
```yaml
payment:
  stripe-payment-integration.md:
    version: "2.4.0"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-17"
    last_tested: "2025-06-17"
    status: "active"
    stripe_api_version: "2024-06-20"
    
  paypal-integration.md:
    version: "1.3.2"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-10"
    last_tested: "2025-06-10"
    status: "active"

cloud-services:
  aws-services-integration.md:
    version: "2.1.3"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-15"
    last_tested: "2025-06-15"
    status: "active"
    
  azure-services-integration.md:
    version: "1.7.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-11"
    last_tested: "2025-06-11"
    status: "active"
```

### Deployment
```yaml
containerization:
  docker-containerization.md:
    version: "2.2.1"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-14"
    last_tested: "2025-06-14"
    status: "active"
    
  kubernetes-deployment.md:
    version: "1.9.0"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-16"
    last_tested: "2025-06-16"
    status: "active"

ci-cd:
  github-actions-pipeline.md:
    version: "2.0.2"
    claude_compatibility: ">= Claude-4.0"
    last_updated: "2025-06-13"
    last_tested: "2025-06-13"
    status: "active"
```

## COMPATIBILITY_MATRIX

### Claude Version Compatibility
```yaml
claude_4.0:
  supported_templates: "all"
  performance: "optimal"
  features: "full_feature_set"
  
claude_3.5:
  supported_templates: "legacy_only"
  performance: "degraded"
  features: "limited"
  deprecation_notice: "Support ends 2025-12-31"
```

### Template Interdependencies
```yaml
authentication_components:
  jwt-authentication.md:
    requires: []
    conflicts_with: []
    enhances:
      - "oauth2-integration.md"
      - "multi-factor-authentication.md"
    compatible_backends:
      - "spring-boot-kotlin-enterprise.md"
      - "node-express-rest-api.md"
      - "kotlin-ktor-microservice.md"
      - "cpp-beast-http-server.md"
  
  oauth2-integration.md:
    requires: 
      - "jwt-authentication.md >= 2.0.0"
    conflicts_with: []
    compatible_backends:
      - "spring-boot-kotlin-enterprise.md >= 1.4.0"
      - "spring-boot-java-microservice.md >= 2.0.0"
  
  multi-factor-authentication.md:
    requires:
      - "jwt-authentication.md >= 2.1.0"
    conflicts_with: []

kotlin_ecosystem:
  spring-boot-kotlin-enterprise.md:
    requires: []
    enhances:
      - "vaadin-spring-boot-fullstack.md"
      - "kotlin-android-native.md"
    compatible_frontends:
      - "react-typescript-spa.md"
      - "vaadin-spring-boot-fullstack.md"
    compatible_mobile:
      - "kotlin-android-native.md"
      - "kotlin-multiplatform-mobile.md"
  
  kotlin-multiplatform-mobile.md:
    requires: []
    enhances:
      - "kotlin-ktor-microservice.md"
      - "spring-boot-kotlin-enterprise.md"
    shared_backend:
      - "kotlin-ktor-microservice.md >= 1.3.0"

vaadin_ecosystem:
  vaadin-spring-boot-fullstack.md:
    requires:
      - "spring-boot-kotlin-enterprise.md >= 1.5.0"
    conflicts_with:
      - "react-typescript-spa.md"
      - "vue-composition-stack.md"
    integrates_with:
      - "relational-database-setup.md"
      - "jwt-authentication.md"

android_ecosystem:
  kotlin-android-native.md:
    requires: []
    enhances:
      - "kotlin-multiplatform-mobile.md"
    compatible_backends:
      - "spring-boot-kotlin-enterprise.md"
      - "kotlin-ktor-microservice.md"
      - "node-express-rest-api.md"
  
  java-android-enterprise.md:
    requires: []
    conflicts_with:
      - "kotlin-android-native.md"
    compatible_backends:
      - "spring-boot-java-microservice.md"
      - "node-express-rest-api.md"

cpp_ecosystem:
  cpp-qt-desktop-app.md:
    requires: []
    conflicts_with: []
    compatible_backends:
      - "cpp-beast-http-server.md"
      - "cpp-crow-rest-api.md"
  
  cpp-beast-http-server.md:
    requires: []
    enhances:
      - "cpp-qt-desktop-app.md"
    compatible_frontends:
      - "react-typescript-spa.md"
      - "cpp-qt-desktop-app.md"

fullstack_combinations:
  react_node_postgresql:
    scenario: "react-typescript-spa.md >= 2.0.0"
    backend: "node-express-rest-api.md >= 2.0.0"
    database: "relational-database-setup.md >= 2.0.0"
    auth: "jwt-authentication.md >= 2.0.0"
    payment: "stripe-payment-integration.md >= 2.0.0"
    tested: "2025-06-18"
    status: "verified"
  
  kotlin_spring_vaadin_postgresql:
    scenario: "vaadin-spring-boot-fullstack.md >= 1.4.0"
    backend: "spring-boot-kotlin-enterprise.md >= 1.6.0"
    database: "relational-database-setup.md >= 2.1.0"
    auth: "jwt-authentication.md >= 2.2.0"
    tested: "2025-06-18"
    status: "verified"
  
  kotlin_android_spring_backend:
    mobile: "kotlin-android-native.md >= 2.2.0"
    backend: "spring-boot-kotlin-enterprise.md >= 1.6.0"
    database: "relational-database-setup.md >= 2.1.0"
    auth: "jwt-authentication.md >= 2.2.0"
  
  kotlin_multiplatform_fullstack:
    shared_code: "kotlin-multiplatform-mobile.md >= 1.8.0"
    backend: "kotlin-ktor-microservice.md >= 1.4.0"
    android: "kotlin-android-native.md >= 2.2.0"
    ios: "kotlin-multiplatform-mobile.md >= 1.8.0"
    web: "kotlin-multiplatform-fullstack.md >= 1.3.0"
    tested: "2025-06-15"
    status: "verified"
  
  java_enterprise_stack:
    backend: "spring-boot-java-microservice.md >= 2.1.0"
    frontend: "react-typescript-spa.md >= 2.1.0"
    mobile: "java-android-enterprise.md >= 1.4.0"
    desktop: "javafx-kotlin-desktop.md >= 1.7.0"
    database: "relational-database-setup.md >= 2.1.0"
    tested: "2025-06-16"
    status: "verified"
  
  cpp_native_stack:
    backend: "cpp-beast-http-server.md >= 1.1.0"
    desktop: "cpp-qt-desktop-app.md >= 1.5.0"
    database: "relational-database-setup.md >= 2.1.0"
    tested: "2025-06-14"
    status: "verified"
```

## DEPRECATION_SCHEDULE

### Currently Deprecated
```yaml
deprecated_templates:
  legacy-react-class-components.md:
    deprecated_since: "2025-03-01"
    removal_date: "2025-09-01"
    replacement: "react-typescript-spa.md"
    migration_guide: "docs/migrations/react-class-to-functional.md"
    
  node-callback-style-api.md:
    deprecated_since: "2025-02-15"
    removal_date: "2025-08-15"
    replacement: "node-express-rest-api.md"
    migration_guide: "docs/migrations/callbacks-to-async-await.md"
    
  spring-boot-java-legacy.md:
    deprecated_since: "2025-04-01"
    removal_date: "2025-10-01"
    replacement: "spring-boot-java-microservice.md"
    migration_guide: "docs/migrations/spring-boot-legacy-to-modern.md"
    reason: "Spring Boot 2.x end of life"
    
  kotlin-android-kapt.md:
    deprecated_since: "2025-05-01"
    removal_date: "2025-11-01"
    replacement: "kotlin-android-native.md"
    migration_guide: "docs/migrations/kapt-to-ksp.md"
    reason: "KAPT deprecated in favor of KSP"
    
  java-android-support-library.md:
    deprecated_since: "2025-01-01"
    removal_date: "2025-07-01"
    replacement: "java-android-enterprise.md"
    migration_guide: "docs/migrations/support-library-to-androidx.md"
    reason: "Android Support Library deprecated"
    
  cpp-boost-beast-legacy.md:
    deprecated_since: "2025-03-15"
    removal_date: "2025-09-15"
    replacement: "cpp-beast-http-server.md"
    migration_guide: "docs/migrations/boost-beast-legacy-to-modern.md"
    reason: "Old Boost Beast API patterns"
```

### Planned Deprecations
```yaml
future_deprecations:
  vue2-options-api.md:
    deprecation_date: "2025-09-01"
    removal_date: "2026-03-01"
    replacement: "vue-composition-stack.md"
    reason: "Vue 2 end-of-life"
    
  angular-14-template.md:
    deprecation_date: "2025-12-01"
    removal_date: "2026-06-01"
    replacement: "angular-enterprise-dashboard.md"
    reason: "Angular 14 no longer LTS"
    
  kotlin-1.8-templates.md:
    deprecation_date: "2025-10-01"
    removal_date: "2026-04-01"
    replacement: "kotlin-2.0-based templates"
    reason: "Kotlin 1.8 compatibility issues"
    
  java-17-spring-boot.md:
    deprecation_date: "2026-01-01"
    removal_date: "2026-07-01"
    replacement: "java-21-spring-boot templates"
    reason: "Java 17 LTS cycle ending"
    
  cpp-17-standard.md:
    deprecation_date: "2025-11-01"
    removal_date: "2026-05-01"
    replacement: "cpp-20-modern-stack.md"
    reason: "C++17 becoming legacy standard"
    
  vaadin-23-templates.md:
    deprecation_date: "2025-08-01"
    removal_date: "2026-02-01"
    replacement: "vaadin-24-enterprise-stack.md"
    reason: "Vaadin 23 end of support"
```

## TESTING_STATUS

### Automated Testing
```yaml
continuous_integration:
  template_validation:
    frequency: "on_every_commit"
    last_run: "2025-06-18T10:30:00Z"
    status: "passing"
    tests_run: 847
    
  claude_compatibility:
    frequency: "daily"
    last_run: "2025-06-18T06:00:00Z"
    status: "passing"
    templates_tested: 156
    
  dependency_updates:
    frequency: "weekly"
    last_run: "2025-06-16T08:00:00Z"
    status: "passing"
    updates_available: 23
```

### Manual Testing
```yaml
user_acceptance_testing:
  last_comprehensive_test: "2025-06-01"
  next_scheduled_test: "2025-07-01"
  templates_requiring_retest:
    - "spring-boot-kotlin-enterprise.md"
    - "kubernetes-deployment.md"
    - "aws-services-integration.md"
  
community_feedback:
  active_issues: 12
  resolved_this_month: 34
  average_resolution_time: "3.2_days"
```

## RELEASE_CALENDAR

### Recent Releases
```yaml
june_2025:
  "2025-06-18":
    - "spring-boot-kotlin-enterprise.md v1.6.0"
    - "modern-react-stack.md v3.0.0"
    - "relational-database-setup.md v2.1.1"
  
  "2025-06-15":
    - "rest-api-standards.md v2.0.3"
    - "aws-services-integration.md v2.1.3"
    - "kotlin-multiplatform-mobile.md v1.9.0"
    - "kotlin-multiplatform-fullstack.md v1.3.1"
  
  "2025-06-16":
    - "spring-boot-java-microservice.md v2.1.4"
    - "javafx-kotlin-desktop.md v1.7.4"
    - "java-enterprise-stack.md v2.0.4"
    - "spring-boot-react-fullstack.md v1.7.2"
  
  "2025-06-17":
    - "kotlin-android-native.md v2.3.1"
    - "stripe-payment-integration.md v2.4.0"
  
  "2025-06-10":
    - "vue-nuxt-ecommerce.md v1.5.1"
    - "paypal-integration.md v1.3.2"
    - "cpp-beast-http-server.md v1.1.0"
```

### Upcoming Releases
```yaml
july_2025:
  "2025-07-01":
    planned:
      - "graphql-federation-gateway.md v1.0.0"
      - "micro-frontend-architecture.md v1.0.0"
      - "kotlin-native-desktop.md v1.0.0"
      - "cpp-20-coroutines-server.md v1.0.0"
    
  "2025-07-15":
    planned:
      - "serverless-framework-stack.md v2.0.0"
      - "python-fastapi-microservices.md v1.5.0"
      - "vaadin-flow-24.5.md v1.0.0"
      - "kotlin-compiler-plugin-dev.md v1.0.0"
      - "java-21-virtual-threads.md v1.0.0"
      - "cpp-modules-cmake.md v1.0.0"

august_2025:
  "2025-08-01":
    planned:
      - "kotlin-wasm-frontend.md v1.0.0"
      - "spring-boot-3.4-features.md v1.0.0"
      - "android-compose-desktop.md v1.0.0"
      - "cpp-23-standard-features.md v1.0.0"
    
  "2025-08-15":
    planned:
      - "kotlin-multiplatform-3.0.md v1.0.0"
      - "vaadin-hilla-integration.md v1.0.0"
      - "java-graalvm-native.md v2.0.0"
      - "cpp-vcpkg-registry.md v1.0.0"
```

## MAINTENANCE_SCHEDULE

### Regular Updates
```yaml
monthly_tasks:
  dependency_updates:
    schedule: "first_monday_of_month"
    next_due: "2025-07-07"
    responsible: "maintenance_team"
    
  security_audit:
    schedule: "second_wednesday_of_month"
    next_due: "2025-07-09"
    responsible: "security_team"
    
  performance_review:
    schedule: "third_friday_of_month"
    next_due: "2025-07-18"
    responsible: "performance_team"

quarterly_tasks:
  comprehensive_testing:
    schedule: "first_week_of_quarter"
    next_due: "2025-10-01"
    duration: "2_weeks"
    
  documentation_review:
    schedule: "second_week_of_quarter"
    next_due: "2025-10-08"
    duration: "1_week"
    
  community_feedback_analysis:
    schedule: "third_week_of_quarter"
    next_due: "2025-10-15"
    duration: "3_days"
```

## CONTRIBUTION_TRACKING

### Template Contributors
```yaml
active_maintainers:
  - name: "Core Team"
    templates_maintained: 87
    last_activity: "2025-06-18"
    
  - name: "Community Contributors"
    templates_contributed: 34
    active_contributors: 23
    last_contribution: "2025-06-17"

contribution_stats:
  total_templates: 156
  community_contributed: 34
  core_team_maintained: 122
  external_contributions_this_month: 8
  pull_requests_merged: 45
  issues_resolved: 67
```

### Quality Metrics
```yaml
template_quality:
  average_claude_compatibility_score: 9.2/10
  average_user_satisfaction: 8.7/10
  documentation_completeness: 94%
  test_coverage: 89%
  
  improvement_trends:
    compatibility_score: "+0.3 this quarter"
    user_satisfaction: "+0.2 this quarter"
    documentation: "+2% this quarter"
    test_coverage: "+4% this quarter"
```

## UPDATE_PROCEDURES

### Version Bump Process
1. **Patch Updates**: Automatic for dependency updates and bug fixes
2. **Minor Updates**: Manual review for new features and improvements
3. **Major Updates**: Community discussion and approval for breaking changes

### Testing Requirements
- All templates must pass automated validation
- Breaking changes require manual testing with Claude Code
- Community feedback integration before major releases

### Documentation Updates
- VERSION_MANIFEST.md updated with every template change
- CHANGELOG.md entries for all version bumps
- Migration guides for breaking changes

---

**This manifest is automatically updated with template changes and manually reviewed monthly by the maintenance team.**