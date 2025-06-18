# Claude Code Templates

A comprehensive collection of structured templates and specifications for Claude Code to create production-ready applications with consistent architecture, best practices, and complete documentation.

## What This Repository Provides

**Complete Application Templates** - End-to-end specifications for building full applications from scratch with Claude Code, including technology stacks, project structure, business logic, and deployment configurations.

**Modular Components** - Reusable building blocks for authentication, payment processing, data persistence, API design, and other common application features that can be combined across different projects.

**Technology Stacks** - Curated combinations of frameworks, libraries, and tools that work well together, with specific versions and configuration guidelines.

**Architecture Patterns** - Implementation guides for proven architectural approaches like microservices, clean architecture, domain-driven design, and event-driven systems.

## Quick Start

### For New Projects
```bash
# 1. Choose a scenario template that matches your project type
# 2. Copy the template content
# 3. Use this prompt with Claude Code:

I want to create a [PROJECT_TYPE] following this exact template:

[PASTE_TEMPLATE_CONTENT]

Project customization:
- PROJECT_NAME: my-awesome-app
- TECH_STACK: [customize as needed]
- DATABASE: [your choice]
- DEPLOYMENT: [your target platform]

Execute Phase 1 completely before moving to Phase 2.
```

### For Existing Projects
```bash
# 1. Use the project analysis template
# 2. Document your current state
# 3. Apply incremental improvements

I have an existing [PROJECT_TYPE] that needs documentation and improvements.

Please analyze my codebase following this template:
[PASTE_ANALYSIS_TEMPLATE]

Then help me create proper documentation and implement improvements incrementally.
```

## Repository Structure

```
claude-code-templates/
├── scenarios/              # Complete application templates
│   ├── web-applications/   # React, Vue, Angular, Next.js apps
│   ├── backend-services/   # APIs, microservices, web services
│   ├── mobile-applications/# React Native, Flutter, PWA
│   ├── desktop-applications/# Electron, Tauri, JavaFX
│   ├── data-applications/  # Analytics, ML, data pipelines
│   └── specialized/        # Blockchain, IoT, games, AR/VR
├── components/             # Reusable modular components
│   ├── authentication/     # Auth patterns and implementations
│   ├── data-persistence/   # Database and storage patterns
│   ├── api-design/         # REST, GraphQL, API standards
│   ├── ui-components/      # Frontend component libraries
│   ├── real-time-features/ # WebSockets, SSE, notifications
│   └── monitoring/         # Logging, metrics, health checks
├── stacks/                 # Technology stack combinations
│   ├── frontend/           # Modern frontend stacks
│   ├── backend/            # Backend technology stacks
│   ├── fullstack/          # Combined frontend/backend
│   ├── mobile/             # Mobile development stacks
│   └── cloud/              # Cloud-native stacks
├── patterns/               # Architecture and design patterns
│   ├── architectural/      # System architecture patterns
│   ├── design-patterns/    # Software design patterns
│   ├── integration/        # Service integration patterns
│   └── security/           # Security implementation patterns
├── integrations/           # Third-party service integrations
│   ├── databases/          # Database setup and configuration
│   ├── cloud-services/     # AWS, Azure, GCP integrations
│   ├── payment/            # Payment processor integrations
│   ├── communication/      # Email, SMS, chat integrations
│   └── ai-ml/              # AI/ML service integrations
├── deployment/             # Deployment and infrastructure
│   ├── containerization/   # Docker, Kubernetes configs
│   ├── ci-cd/              # Pipeline configurations
│   ├── cloud-deployment/   # Cloud platform deployments
│   └── infrastructure/     # Infrastructure as code
├── testing/                # Testing strategies and frameworks
│   ├── strategies/         # Testing approaches and plans
│   ├── frameworks/         # Test framework configurations
│   └── tools/              # Testing tools and utilities
├── security/               # Security patterns and compliance
│   ├── practices/          # Secure coding practices
│   ├── configurations/     # Security configurations
│   └── compliance/         # Regulatory compliance guides
├── performance/            # Performance optimization
│   ├── optimization/       # Performance tuning guides
│   ├── monitoring/         # Performance monitoring setup
│   └── scaling/            # Scaling strategies
└── examples/               # Real-world implementations
    ├── case-studies/       # Detailed implementation examples
    ├── reference-implementations/ # Working example projects
    └── tutorials/          # Step-by-step guides
```

## Template Categories

### 🌐 Web Applications
- **react-typescript-spa.md** - Modern React SPA with TypeScript, Vite, Tailwind
- **react-nextjs-fullstack.md** - Full-stack Next.js with API routes and database
- **vue-nuxt-ecommerce.md** - E-commerce platform with Nuxt.js and Vue 3
- **angular-enterprise-dashboard.md** - Enterprise dashboard with Angular and NgRx
- **spring-boot-kotlin-vaadin.md** - Enterprise Java application with Vaadin UI

### 🔗 Backend Services
- **node-express-rest-api.md** - RESTful API with Express, TypeScript, PostgreSQL
- **spring-boot-kotlin-enterprise.md** - Enterprise Java service with Spring Boot
- **fastapi-python-async-api.md** - High-performance async Python API
- **dotnet-core-enterprise-api.md** - .NET Core enterprise API service

### 📱 Mobile Applications
- **react-native-cross-platform.md** - Cross-platform mobile with React Native
- **flutter-dart-mobile-app.md** - Flutter application with Dart
- **pwa-mobile-first.md** - Progressive Web App optimized for mobile

### 🔧 Specialized Applications
- **data-science-python-platform.md** - Data science environment with Jupyter
- **blockchain-dapp-ethereum.md** - Decentralized application on Ethereum
- **real-time-chat-application.md** - Real-time messaging with WebSockets

## How to Use Templates

### 1. Choose Your Template
Select the template that best matches your project type and requirements. Each template includes:
- Complete technology stack specification
- Project structure and file organization
- Implementation phases with specific tasks
- Testing requirements and strategies
- Security practices and compliance
- Deployment and infrastructure setup

### 2. Customize Variables
Replace template variables with your project-specific values:
```markdown
PROJECT_NAME: {{your_project_name}}
BASE_PACKAGE: {{your_package_structure}}
DATABASE_TYPE: {{postgresql|mysql|mongodb}}
AUTH_PROVIDER: {{jwt|oauth2|saml}}
DEPLOYMENT_TARGET: {{aws|azure|gcp|on-premise}}
```

### 3. Add Modular Components
Enhance your base template with additional components:
```markdown
@include: jwt-authentication.md
@include: stripe-payment-integration.md
@include: email-service-integration.md
@include: real-time-notifications.md
```

### 4. Request Implementation
Use the complete specification with Claude Code:
```
I want to create a [PROJECT_TYPE] following this exact template:

[PASTE_COMPLETE_TEMPLATE]

Project Variables:
- PROJECT_NAME: my-project
- [other customizations]

Please start with Phase 1: Foundation Setup and implement it completely before proceeding to Phase 2.
```

## Template Features

### ✅ Production-Ready Standards
- Comprehensive security practices
- Performance optimization guidelines
- Scalability considerations
- Monitoring and observability
- Error handling and logging

### ✅ Best Practices Enforcement
- Code organization patterns
- Testing strategies (unit, integration, e2e)
- Documentation requirements
- CI/CD pipeline configurations
- Code quality standards

### ✅ Technology Alignment
- Latest stable versions of frameworks
- Compatible dependency combinations
- Proven architectural patterns
- Industry-standard tooling

### ✅ Modular Architecture
- Reusable component specifications
- Mix-and-match capabilities
- Progressive enhancement
- Incremental development support

## Integration with Your Workflow

### Project Setup
```bash
# In your project root, create Claude Code documentation
mkdir -p .claude-code docs/claude-code

# Copy relevant templates to your project
cp templates/scenarios/react-typescript-spa.md docs/claude-code/project-spec.md
cp templates/components/jwt-authentication.md docs/claude-code/components/
```

### Development Process
1. **Planning**: Choose base template and required components
2. **Customization**: Adapt templates to project requirements
3. **Implementation**: Use templates with Claude Code in phases
4. **Documentation**: Maintain updated specs alongside code
5. **Evolution**: Update templates based on lessons learned

### Team Collaboration
- Store project-specific templates in your repository
- Use templates for code review standards
- Share component specifications across projects
- Maintain consistency across team members

## Contributing

### Adding New Templates
1. Follow the established template format specification
2. Include all required sections (Context, Requirements, Guidelines, etc.)
3. Test templates with Claude Code to ensure they work
4. Add examples and validation scripts
5. Update this README with new template information

### Improving Existing Templates
1. Keep templates current with latest framework versions
2. Add new best practices and security requirements
3. Enhance with community feedback and real-world usage
4. Maintain backward compatibility where possible

### Template Format
All templates follow this structure:
```markdown
# [Template Name] - Claude Code Instructions

## CONTEXT
## MANDATORY REQUIREMENTS
## STRICT GUIDELINES
## IMPLEMENTATION STRATEGY
## CLAUDE_CODE_COMMANDS
## VALIDATION_SCRIPTS
## PROJECT_VARIABLES
## CONDITIONAL_REQUIREMENTS
## INCLUDE_MODULES
## VALIDATION CHECKLIST
```

See [TEMPLATE_SPEC.md](./TEMPLATE_SPEC.md) for complete format documentation.

## Support and Resources

### Documentation
- **[Template Specification](./TEMPLATE_SPEC.md)** - Complete template format guide
- **[Usage Examples](./examples/)** - Real-world implementation examples
- **[Best Practices](./docs/best-practices.md)** - Guidelines for effective use

### Community
- Share your successful implementations
- Report issues or gaps in templates
- Suggest new templates or improvements
- Contribute examples and case studies

### Version Information
- **Current Version**: 1.0.0
- **Last Updated**: June 2025
- **Compatibility**: Claude Sonnet 4 and later
- **Minimum Requirements**: Claude Code access

## License

This collection is provided under the MIT License. See [LICENSE](./LICENSE) for full details.

---

**Start building better applications faster with structured, battle-tested templates that help Claude Code understand exactly what you want to create.**