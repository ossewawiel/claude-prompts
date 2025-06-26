# Technology Stack Analysis & Modernization Prompt

## CONTEXT
- **Purpose**: Analyze existing project's technology stack for currency, security, and modernization opportunities
- **Input**: Completed project analysis from previous phase
- **Output**: Technology stack modernization recommendations document
- **Analysis Date**: [current_date]
- **Scope**: Technology versions, security vulnerabilities, performance implications, and modernization paths

---

## PHASE 1: TECHNOLOGY STACK CURRENCY ANALYSIS

### Core Technology Assessment
Analyze each technology component from the project analysis and evaluate:

**For each identified technology:**

1. **Version Currency Analysis**
   - Current version used in project: [detected_version]
   - Latest stable version available: [research_latest_version]
   - Latest LTS/stable version: [lts_version]
   - Version gap analysis: [versions_behind]
   - End-of-life status: [eol_date_if_applicable]

2. **Security Evaluation**
   - Known CVE vulnerabilities in current version
   - Critical security patches available
   - Security support status (actively maintained/deprecated)
   - Recommended minimum secure version

3. **Performance & Feature Analysis**
   - Major performance improvements in newer versions
   - New features that could benefit the project
   - Breaking changes that would require migration effort
   - Community adoption of newer versions

### Technology Categories to Evaluate

#### Frontend Stack Analysis
- **Primary Framework**: [React/Vue/Angular/etc]
  - Version: [current] → [recommended]
  - Migration effort: [low/medium/high]
  - Breaking changes: [list major breaking changes]
  - Benefits of upgrade: [performance/security/features]

- **Build Tools**: [Webpack/Vite/Parcel/etc]
- **Package Manager**: [npm/yarn/pnpm]
- **Styling Framework**: [Bootstrap/Tailwind/etc]
- **State Management**: [Redux/Vuex/etc]
- **Testing Framework**: [Jest/Cypress/etc]

#### Backend Stack Analysis
- **Runtime Environment**: [Node.js/JVM/Python/etc]
- **Web Framework**: [Express/Spring Boot/Django/etc]
- **Database**: [PostgreSQL/MySQL/MongoDB/etc]
- **ORM/ODM**: [Prisma/Hibernate/Mongoose/etc]
- **Authentication**: [Passport/Spring Security/etc]
- **Testing Framework**: [JUnit/Mocha/pytest/etc]

#### Infrastructure & DevOps Analysis
- **Containerization**: [Docker/Podman]
- **Orchestration**: [Kubernetes/Docker Compose]
- **CI/CD Platform**: [GitHub Actions/Jenkins/etc]
- **Cloud Services**: [AWS/Azure/GCP services used]
- **Monitoring**: [Application and infrastructure monitoring tools]

---

## PHASE 2: COMPATIBILITY MATRIX EVALUATION

### Cross-Component Compatibility
Using the Claude Code template version manifest as reference:

1. **Template Compatibility Check**
   - Match current stack against Claude Code templates
   - Identify applicable modernization templates
   - Check compatibility requirements for stack combinations

2. **Dependency Conflict Analysis**
   - Identify potential conflicts between technology versions
   - Evaluate peer dependency requirements
   - Check for deprecated dependencies

3. **Integration Point Analysis**
   - API compatibility between frontend and backend
   - Database driver compatibility
   - Third-party service integration compatibility

---

## PHASE 3: SECURITY & COMPLIANCE ASSESSMENT

### Security Vulnerability Analysis
1. **CVE Database Check**
   - Run security audit on all dependencies
   - Identify high/critical severity vulnerabilities
   - Check for known exploits in production

2. **Dependency Security Scan**
   - Analyze package.json/pom.xml/requirements.txt for vulnerable packages
   - Check for packages with no active maintenance
   - Evaluate alternative secure packages

3. **Compliance Requirements**
   - GDPR/CCPA compliance implications
   - Industry-specific compliance requirements
   - Security framework compliance (SOC2, ISO 27001, etc.)

---

## PHASE 4: TECHNICAL DEBT ANALYSIS

### Technology Debt Classification
Categorize identified technology gaps by debt type:

1. **Security Debt**
   - CVE vulnerabilities in current versions
   - End-of-life technologies with no security support
   - Dependencies with critical security issues
   - Missing security patches

2. **Performance Debt**
   - Framework versions with known performance limitations
   - Database versions with suboptimal query performance
   - Build tools causing slow development cycles
   - Memory leaks or inefficient resource usage in current versions

3. **Maintainability Debt**
   - Deprecated APIs being used
   - Technologies with declining community support
   - Incompatible version combinations causing instability
   - Missing features that force workarounds

4. **Compliance Debt**
   - Technologies that don't meet current compliance requirements
   - Missing support for required standards
   - Outdated cryptographic implementations

### Technical Debt Assessment Template

For each identified technology gap:

**Technical Debt Item:**
```markdown
#### [Technology Name]: [current_version] vs [recommended_version]

**Debt Type**: [Security/Performance/Maintainability/Compliance]
**Severity**: [Critical/High/Medium/Low]
**Impact**: [Description of current limitations or risks]

**Specific Issues:**
- [Concrete problems caused by current version]
- [Missing capabilities affecting development]
- [Performance bottlenecks identified]
- [Security vulnerabilities present]

**Gap Analysis:**
- **Missing Features**: [Features available in newer versions]
- **Performance Gaps**: [Quantified performance differences]
- **Security Gaps**: [Known vulnerabilities and missing patches]
- **Compatibility Issues**: [Problems with other technologies]

**Current Workarounds:**
- [Describe any current workarounds or hacks needed]
- [Technical debt accumulated due to version limitations]
```

---

## PHASE 5: TECHNICAL DEBT DOCUMENTATION

### Create Technical Debt Analysis Document

Generate: `TECHNICAL_DEBT_ANALYSIS.md`

**Document Structure:**
```markdown
# Technology Stack Technical Debt Analysis

## Executive Summary
- Overall technology health score: [Score/10]
- Critical security vulnerabilities found: [count]
- High-impact performance issues: [count]
- Total technical debt items identified: [count]

## Current Stack Assessment

### Technology Health Matrix
| Component | Current Version | Latest Version | Health Status | Security Risk | Technical Debt Level |
|-----------|----------------|----------------|---------------|---------------|---------------------|
| [Framework] | [version] | [latest] | [Good/Warning/Critical] | [Low/Medium/High] | [Low/Medium/High] |

## Technical Debt Inventory

### Critical Security Debt
1. **[Technology Name]**
   - **Issue**: [Specific security vulnerability or EOL status]
   - **Impact**: [Potential security risks]
   - **Evidence**: [CVE numbers, security advisories]

### Performance Debt
1. **[Technology Name]**
   - **Issue**: [Performance limitations in current version]
   - **Impact**: [Quantified performance impact]
   - **Evidence**: [Benchmarks, known issues]

### Maintainability Debt
1. **[Technology Name]**
   - **Issue**: [Deprecated features, compatibility issues]
   - **Impact**: [Development productivity impact]
   - **Evidence**: [Documentation, community reports]

### Compliance Debt
1. **[Technology Name]**
   - **Issue**: [Compliance requirement gaps]
   - **Impact**: [Business risk implications]
   - **Evidence**: [Compliance standards, audit findings]

## Technology Gap Analysis

### Current vs. Recommended Technology Stack
```yaml
current_stack:
  frontend:
    framework: [current_framework_version]
    build_tool: [current_build_tool]
  backend:
    runtime: [current_runtime_version]
    framework: [current_framework_version]
    database: [current_database_version]

recommended_stack:
  frontend:
    framework: [recommended_framework_version]
    build_tool: [recommended_build_tool]
  backend:
    runtime: [recommended_runtime_version]
    framework: [recommended_framework_version]
    database: [recommended_database_version]
```

### Version Gap Summary
- **Major versions behind**: [count and list]
- **Security patches missing**: [count and critical ones]
- **End-of-life technologies in use**: [list]
- **Deprecated features being used**: [list]

## Impact Assessment

### Business Impact
- **Security Risk Level**: [Low/Medium/High/Critical]
- **Performance Impact**: [Description of current performance limitations]
- **Development Velocity Impact**: [How technical debt slows development]
- **Compliance Risk**: [Regulatory or standard compliance gaps]

### Technical Impact
- **Code Quality Issues**: [Problems caused by outdated technologies]
- **Integration Difficulties**: [Compatibility problems between components]
- **Testing Challenges**: [Testing limitations with current stack]
- **Deployment Complications**: [Deployment issues due to old technologies]

## Dependency Analysis

### Vulnerable Dependencies
| Package | Current Version | Vulnerability | Severity | Fixed In Version |
|---------|----------------|---------------|----------|------------------|
| [package] | [version] | [CVE-ID] | [severity] | [fixed_version] |

### Outdated Dependencies
| Package | Current Version | Latest Version | Versions Behind | Maintenance Status |
|---------|----------------|----------------|-----------------|-------------------|
| [package] | [version] | [latest] | [count] | [active/deprecated] |

## Architecture Debt

### Structural Issues
- **Technology Mismatches**: [Incompatible version combinations]
- **Missing Modern Patterns**: [Outdated architectural approaches]
- **Integration Complexity**: [Unnecessary complexity due to old technologies]

### Development Environment Debt
- **Build System Issues**: [Problems with current build configuration]
- **Testing Framework Limitations**: [Testing capabilities restricted by old versions]
- **Development Tool Compatibility**: [IDE/tooling issues with current stack]

## Recommendations Summary

### Technology Stack Improvements Needed
1. **Critical Security Updates**
   - [List technologies requiring immediate security updates]

2. **Performance Enhancement Opportunities**
   - [Technologies with significant performance improvements available]

3. **Maintainability Improvements**
   - [Technologies that would improve code quality and developer experience]

4. **Compliance Requirements**
   - [Technologies needed to meet compliance standards]

### Modernization Benefits
- **Security**: [Security improvements from stack modernization]
- **Performance**: [Expected performance gains]
- **Developer Experience**: [Productivity improvements]
- **Maintainability**: [Code quality and maintenance improvements]

## Claude Code Template Compatibility

### Applicable Templates
- **Current Stack Templates**: [Templates matching current technology versions]
- **Target Stack Templates**: [Templates for recommended modern stack]
- **Migration Guidance**: [Available templates for modernization path]

### Template Integration Opportunities
- [How Claude Code templates could assist with current technical debt]
- [Templates that provide better practices for identified technologies]

## Conclusion

### Technical Debt Summary
- **Total Debt Score**: [Calculated score based on severity and impact]
- **Primary Debt Categories**: [Main areas of concern]
- **Business Risk Level**: [Overall assessment of risk to business]

### Key Findings
1. [Most critical technical debt item]
2. [Highest impact performance issue]
3. [Most significant security concern]
4. [Biggest maintainability challenge]
```

---

## ANALYSIS GUIDELINES

### Research Methodology
1. **Use Official Sources**: Check official documentation, release notes, and changelogs
2. **Security Databases**: Consult CVE databases, GitHub security advisories, Snyk/npm audit
3. **Community Insights**: Review adoption rates, community discussions, migration experiences
4. **Performance Benchmarks**: Look for published performance comparisons and benchmarks

### Evaluation Criteria
1. **Security**: Vulnerability count, patch availability, security support status
2. **Performance**: Known performance issues, benchmark differences, resource usage
3. **Maintainability**: Deprecated features, community support, compatibility issues
4. **Ecosystem Health**: Community size, package availability, long-term viability
5. **Technical Debt Impact**: Development velocity impact, code quality implications

### Risk Assessment Framework
- **Critical**: Security vulnerabilities, end-of-life technologies
- **High**: Major performance issues, deprecated features in active use
- **Medium**: Minor version gaps, declining community support
- **Low**: Optional feature updates, non-critical improvements

---

## SUCCESS CRITERIA

✅ **Complete technology inventory with current vs. latest versions**  
✅ **Security vulnerability assessment completed**  
✅ **Technical debt categorized by type and severity**  
✅ **Impact assessment for each identified gap**  
✅ **Technology health matrix with scoring**  
✅ **Dependency analysis with vulnerability mapping**  
✅ **Architecture debt identification**  
✅ **Claude Code template compatibility assessment**

---

## DELIVERABLES CHECKLIST

- [ ] `TECHNICAL_DEBT_ANALYSIS.md` - Comprehensive technical debt documentation
- [ ] Technology health matrix with scoring
- [ ] Technical debt inventory by category
- [ ] Security vulnerability assessment
- [ ] Performance gap analysis
- [ ] Dependency analysis with outdated/vulnerable packages
- [ ] Architecture debt assessment
- [ ] Claude Code template compatibility evaluation

**Note**: This analysis should be documentation-only. No code changes should be made during this assessment phase. The focus is entirely on identifying and documenting technical debt without prescribing implementation timelines or work plans.