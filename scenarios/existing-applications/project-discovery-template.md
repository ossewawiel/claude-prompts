
# Existing Project Analysis Template

## PROJECT_DISCOVERY
**Analysis Date**: [current_date]
**Project Path**: [project_directory]
**Team Size**: [number_of_developers]
**Estimated Age**: [project_timeline]
**Business Domain**: [inferred_from_code]

## TECHNOLOGY_STACK_ANALYSIS
### Frontend Stack
- **Framework**: [detected_framework_and_version]
- **Language**: [primary_language]
- **Build Tools**: [build_system]
- **Dependencies**: [key_packages_from_package_json]
- **Styling**: [css_framework_or_approach]

### Backend Stack
- **Runtime**: [server_technology]
- **Framework**: [web_framework]
- **Database**: [database_type_and_version]
- **ORM/ODM**: [data_access_layer]
- **Authentication**: [auth_mechanism]

### Infrastructure
- **Deployment**: [deployment_method]
- **Environment Management**: [env_config_approach]
- **Testing**: [testing_frameworks_found]
- **CI/CD**: [pipeline_configuration]

## ARCHITECTURE_ANALYSIS
### Project Structure
```
[generated_from_file_analysis]
project/
├── [discovered_folders]/
│   ├── [sub_components]/
│   └── [patterns_identified]/
└── [configuration_files]/
```

### Architectural Patterns
- **Overall Pattern**: [MVC|MVP|MVVM|Clean|Layered|etc]
- **Data Flow**: [unidirectional|bidirectional|event_driven]
- **State Management**: [approach_used]
- **Communication**: [REST|GraphQL|WebSockets|etc]

## DATA_MODEL_REVERSE_ENGINEERING
### Entities Discovered
```yaml
entities:
  [entity_name]:
    table: [database_table]
    fields:
      - name: [field_name]
        type: [data_type]
        constraints: [nullable|unique|etc]
    relationships:
      - type: [has_many|belongs_to|many_to_many]
        target: [related_entity]
```

### Database Schema
```sql
-- Reconstructed schema based on models/migrations
[generated_schema_from_code_analysis]
```

## FEATURE_INVENTORY
### Core Features Identified
1. **[Feature_Name]**
   - **Location**: [file_paths]
   - **Endpoints**: [api_routes_found]
   - **UI Components**: [frontend_components]
   - **Business Logic**: [service_layer_code]

### Integration Points
- **External APIs**: [third_party_integrations]
- **Payment Systems**: [payment_providers]
- **Authentication Providers**: [auth_services]
- **File Storage**: [storage_solutions]

## CODE_QUALITY_ASSESSMENT
### Technical Debt Indicators
- **Code Duplication**: [duplication_level]
- **Test Coverage**: [coverage_percentage]
- **Documentation**: [documentation_status]
- **Security Issues**: [security_concerns]
- **Performance Issues**: [performance_bottlenecks]

### Best Practices Compliance
- **Naming Conventions**: [consistency_level]
- **Error Handling**: [error_handling_approach]
- **Logging**: [logging_implementation]
- **Configuration Management**: [config_approach]

## GAPS_AND_RECOMMENDATIONS
### Missing Documentation
- [ ] API documentation
- [ ] Database schema documentation
- [ ] Deployment instructions
- [ ] Development setup guide
- [ ] Business logic documentation

### Technical Improvements
- [ ] [specific_recommendations]
- [ ] [security_improvements]
- [ ] [performance_optimizations]
- [ ] [testing_enhancements]
