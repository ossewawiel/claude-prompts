# Vaadin Component Naming Conventions - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: simple
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Views and Layouts
```kotlin
// Views: PascalCase + View suffix
@Route("users")
@PageTitle("User Management")
class UserListView : VerticalLayout() {
    // Implementation
}

@Route("users/create")
@PageTitle("Create User")
class UserCreateView : VerticalLayout() {
    // Implementation
}

@Route("dashboard")
@PageTitle("Dashboard")
class DashboardView : VerticalLayout() {
    // Implementation
}

// Layout classes: PascalCase + Layout suffix
class MainLayout : AppLayout() {
    // Implementation
}

class SidebarLayout : VerticalLayout() {
    // Implementation
}

class HeaderLayout : HorizontalLayout() {
    // Implementation
}
```

### Components and Fields
```kotlin
// Component fields: camelCase with component type suffix
class UserCreateView : VerticalLayout() {
    // Form fields
    private val firstNameField = TextField("First Name")
    private val lastNameField = TextField("Last Name")
    private val emailField = EmailField("Email Address")
    private val phoneField = TextField("Phone Number")
    private val birthDateField = DatePicker("Date of Birth")
    
    // Buttons
    private val saveButton = Button("Save")
    private val cancelButton = Button("Cancel")
    private val deleteButton = Button("Delete")
    
    // Other components
    private val userGrid = Grid<User>()
    private val statusComboBox = ComboBox<UserStatus>("Status")
    private val avatarUpload = Upload()
    private val confirmDialog = ConfirmDialog()
}

// Boolean fields: is/has/can prefix
private val isActiveCheckbox = Checkbox("Is Active")
private val hasPermissionCheckbox = Checkbox("Has Permission")
private val canEditCheckbox = Checkbox("Can Edit")
```

## IMPLEMENTATION STRATEGY

### Component IDs and CSS Classes
```kotlin
// Component IDs: kebab-case
firstNameField.id.set("first-name-field")
lastNameField.id.set("last-name-field")
saveButton.id.set("save-button")
userGrid.id.set("user-grid")

// CSS class names: kebab-case with component context
firstNameField.addClassNames("user-form-field", "required-field")
saveButton.addClassNames("primary-button", "form-action")
userGrid.addClassNames("data-grid", "user-list")
confirmDialog.addClassNames("confirmation-dialog", "delete-confirmation")

// Theme variants: use Vaadin constants
saveButton.addThemeVariants(ButtonVariant.LUMO_PRIMARY)
deleteButton.addThemeVariants(ButtonVariant.LUMO_ERROR)
cancelButton.addThemeVariants(ButtonVariant.LUMO_TERTIARY)
```

### Event Handlers and Listeners
```kotlin
// Event handler methods: handle + ComponentAction format
class UserCreateView : VerticalLayout() {
    
    private fun handleSaveButtonClick() {
        // Save user logic
    }
    
    private fun handleCancelButtonClick() {
        // Cancel operation logic
    }
    
    private fun handleUserGridSelection(user: User) {
        // Grid selection logic
    }
    
    private fun handleFormValidation(): Boolean {
        // Validation logic
        return true
    }
    
    // Component listener registration
    private fun configureEventListeners() {
        saveButton.addClickListener { handleSaveButtonClick() }
        cancelButton.addClickListener { handleCancelButtonClick() }
        userGrid.addSelectionListener { event ->
            event.firstSelectedItem.ifPresent { user ->
                handleUserGridSelection(user)
            }
        }
    }
}
```

### Data Providers and Services
```kotlin
// Data providers: descriptive + DataProvider suffix
class UserListView : VerticalLayout() {
    private val userDataProvider = DataProvider.fromCallbacks(
        { query -> userService.fetchUsers(query) },
        { query -> userService.countUsers(query) }
    )
    
    private val departmentDataProvider = DataProvider.ofCollection(
        departmentService.getAllDepartments()
    )
}

// Service injection: camelCase with service name
class UserCreateView : VerticalLayout() {
    private val userService: UserService
    private val validationService: ValidationService
    private val notificationService: NotificationService
    
    constructor(
        userService: UserService,
        validationService: ValidationService,
        notificationService: NotificationService
    ) {
        this.userService = userService
        this.validationService = validationService
        this.notificationService = notificationService
    }
}
```

### Form Components and Validation
```kotlin
// Form layouts: descriptive + Form suffix
class UserDetailsForm : FormLayout() {
    // Form fields grouped logically
    private val personalInfoSection = createPersonalInfoSection()
    private val contactInfoSection = createContactInfoSection()
    private val preferencesSection = createPreferencesSection()
    
    private fun createPersonalInfoSection(): Component {
        return FormLayout().apply {
            addFormItem(firstNameField, "First Name")
            addFormItem(lastNameField, "Last Name")
            addFormItem(birthDateField, "Date of Birth")
        }
    }
}

// Validation methods: validate + FieldName format
private fun validateFirstName(): Boolean {
    val isValid = firstNameField.value.isNotBlank()
    if (!isValid) {
        firstNameField.isInvalid = true
        firstNameField.errorMessage = "First name is required"
    }
    return isValid
}

private fun validateEmailAddress(): Boolean {
    val email = emailField.value
    val isValid = email.isNotBlank() && email.contains("@")
    if (!isValid) {
        emailField.isInvalid = true
        emailField.errorMessage = "Valid email address is required"
    }
    return isValid
}
```

### Dialog and Window Components
```kotlin
// Dialog classes: PascalCase + Dialog suffix
class UserEditDialog(private val user: User) : Dialog() {
    private val userForm = UserDetailsForm()
    private val saveButton = Button("Save")
    private val cancelButton = Button("Cancel")
    
    init {
        configureDialog()
        configureEventListeners()
    }
    
    private fun configureDialog() {
        headerTitle = "Edit User"
        isModal = true
        isDraggable = true
        isResizable = true
    }
}

class ConfirmDeleteDialog(
    private val itemName: String,
    private val onConfirm: () -> Unit
) : ConfirmDialog() {
    
    init {
        header = "Confirm Deletion"
        text = "Are you sure you want to delete '$itemName'? This action cannot be undone."
        confirmText = "Delete"
        cancelText = "Cancel"
        isConfirmButtonTheme = "error primary"
        
        addConfirmListener { onConfirm() }
    }
}
```

### Grid Columns and Renderers
```kotlin
// Grid configuration: configure + ComponentName format
private fun configureUserGrid() {
    userGrid.apply {
        // Column definitions: camelCase property names
        addColumn(User::firstName).apply {
            header = "First Name"
            isSortable = true
            isResizable = true
            key = "firstName"
        }
        
        addColumn(User::lastName).apply {
            header = "Last Name"
            isSortable = true
            key = "lastName"
        }
        
        addColumn(User::emailAddress).apply {
            header = "Email"
            isSortable = true
            key = "email"
        }
        
        // Custom renderers: create + ColumnName + Renderer format
        addColumn(createStatusRenderer()).apply {
            header = "Status"
            key = "status"
        }
        
        addColumn(createActionsRenderer()).apply {
            header = "Actions"
            key = "actions"
            isAutoWidth = true
        }
    }
}

private fun createStatusRenderer(): Renderer<User> {
    return ComponentRenderer { user ->
        Span(user.status.displayName).apply {
            addClassNames("status-badge", "status-${user.status.name.lowercase()}")
        }
    }
}

private fun createActionsRenderer(): Renderer<User> {
    return ComponentRenderer { user ->
        HorizontalLayout().apply {
            add(
                Button("Edit") { handleEditUser(user) }.apply {
                    addThemeVariants(ButtonVariant.LUMO_SMALL)
                },
                Button("Delete") { handleDeleteUser(user) }.apply {
                    addThemeVariants(ButtonVariant.LUMO_SMALL, ButtonVariant.LUMO_ERROR)
                }
            )
        }
    }
}
```

## CLAUDE_CODE_COMMANDS

```bash
# Run Vaadin development server
mvn spring-boot:run

# Build production bundle
mvn clean package -Pproduction

# Check CSS class usage
grep -r "addClassName" src/main/kotlin/
```

## VALIDATION_CHECKLIST
- [ ] All views use PascalCase + View suffix
- [ ] All components use camelCase + component type suffix
- [ ] Component IDs use kebab-case
- [ ] CSS classes use kebab-case
- [ ] Event handlers use handle + Action format
- [ ] Form validation methods use validate + Field format
- [ ] Dialog classes use PascalCase + Dialog suffix
- [ ] Grid columns have descriptive keys
- [ ] Boolean fields use is/has/can prefix