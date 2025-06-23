# Vaadin UI Testing Strategy - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: medium
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Dependencies
```kotlin
// build.gradle.kts
dependencies {
    testImplementation("com.vaadin:vaadin-testbench-junit5:9.0.0")
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.testcontainers:junit-jupiter:1.19.3")
    testImplementation("org.seleniumhq.selenium:selenium-chrome-driver:4.15.0")
    testImplementation("io.github.bonigarcia:webdrivermanager:5.6.2")
    
    // For component unit testing
    testImplementation("com.vaadin:vaadin-test-helpers:24.2.0")
    testImplementation("org.mockito.kotlin:mockito-kotlin:5.1.0")
}
```

### TestBench Configuration
```kotlin
// Base test class for UI tests
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestMethodOrder(OrderAnnotation::class)
abstract class BaseUITest : TestBenchTestCase() {
    
    @LocalServerPort
    private var port: Int = 0
    
    @BeforeAll
    fun setupClass() {
        WebDriverManager.chromedriver().setup()
        driver = ChromeDriver(ChromeOptions().apply {
            addArguments("--headless")
            addArguments("--no-sandbox")
            addArguments("--disable-dev-shm-usage")
            addArguments("--disable-gpu")
            addArguments("--window-size=1920,1080")
        })
        
        testBench().resizeViewPortTo(1920, 1080)
    }
    
    @AfterAll
    fun tearDownClass() {
        driver?.quit()
    }
    
    @BeforeEach
    fun setUp() {
        driver.get("http://localhost:$port")
    }
    
    protected fun navigateTo(route: String) {
        driver.get("http://localhost:$port/$route")
    }
    
    protected fun waitForVaadin() {
        testBench().waitForVaadin()
    }
}
```

## IMPLEMENTATION STRATEGY

### Page Object Pattern
```kotlin
// Page Object for User List View
class UserListViewPageObject(driver: WebDriver) : TestBenchTestCase() {
    
    init {
        this.driver = driver
    }
    
    // Component selectors
    private fun getUserGrid() = $(GridElement::class.java).id("user-grid")
    private fun getSearchField() = $(TextFieldElement::class.java).id("search-field")
    private fun getAddButton() = $(ButtonElement::class.java).id("add-user-button")
    private fun getDeleteButton() = $(ButtonElement::class.java).id("delete-button")
    private fun getConfirmDialog() = $(ConfirmDialogElement::class.java).first()
    
    // Page actions
    fun searchForUser(searchTerm: String): UserListViewPageObject {
        getSearchField().setValue(searchTerm)
        testBench().waitForVaadin()
        return this
    }
    
    fun clickAddUser(): UserCreateDialogPageObject {
        getAddButton().click()
        testBench().waitForVaadin()
        return UserCreateDialogPageObject(driver)
    }
    
    fun selectUserByEmail(email: String): UserListViewPageObject {
        val grid = getUserGrid()
        val row = grid.getRow(getUserRowIndex(email))
        row.click()
        testBench().waitForVaadin()
        return this
    }
    
    fun deleteSelectedUser(): UserListViewPageObject {
        getDeleteButton().click()
        testBench().waitForVaadin()
        getConfirmDialog().confirm()
        testBench().waitForVaadin()
        return this
    }
    
    // Verification methods
    fun verifyUserExists(email: String): Boolean {
        return try {
            getUserRowIndex(email) >= 0
        } catch (e: Exception) {
            false
        }
    }
    
    fun verifyUserCount(expectedCount: Int): UserListViewPageObject {
        val grid = getUserGrid()
        assertThat(grid.rowCount).isEqualTo(expectedCount)
        return this
    }
    
    fun verifySearchResults(searchTerm: String): UserListViewPageObject {
        val grid = getUserGrid()
        for (i in 0 until grid.rowCount) {
            val row = grid.getRow(i)
            val cellText = row.getCell(1).text + " " + row.getCell(2).text // firstName + lastName
            assertThat(cellText.lowercase()).contains(searchTerm.lowercase())
        }
        return this
    }
    
    private fun getUserRowIndex(email: String): Int {
        val grid = getUserGrid()
        for (i in 0 until grid.rowCount) {
            val row = grid.getRow(i)
            if (row.getCell(3).text == email) { // Assuming email is in column 3
                return i
            }
        }
        throw NoSuchElementException("User with email $email not found")
    }
}

// Page Object for User Create Dialog
class UserCreateDialogPageObject(driver: WebDriver) : TestBenchTestCase() {
    
    init {
        this.driver = driver
    }
    
    private fun getFirstNameField() = $(TextFieldElement::class.java).id("first-name-field")
    private fun getLastNameField() = $(TextFieldElement::class.java).id("last-name-field")
    private fun getEmailField() = $(EmailFieldElement::class.java).id("email-field")
    private fun getSaveButton() = $(ButtonElement::class.java).id("save-button")
    private fun getCancelButton() = $(ButtonElement::class.java).id("cancel-button")
    
    fun fillUserDetails(firstName: String, lastName: String, email: String): UserCreateDialogPageObject {
        getFirstNameField().setValue(firstName)
        getLastNameField().setValue(lastName)
        getEmailField().setValue(email)
        return this
    }
    
    fun clickSave(): UserListViewPageObject {
        getSaveButton().click()
        testBench().waitForVaadin()
        return UserListViewPageObject(driver)
    }
    
    fun clickCancel(): UserListViewPageObject {
        getCancelButton().click()
        testBench().waitForVaadin()
        return UserListViewPageObject(driver)
    }
    
    fun verifyValidationError(fieldId: String, expectedMessage: String): UserCreateDialogPageObject {
        val field = $(TextFieldElement::class.java).id(fieldId)
        assertThat(field.isInvalid).isTrue()
        assertThat(field.errorMessage).isEqualTo(expectedMessage)
        return this
    }
}
```

### UI Integration Tests
```kotlin
@TestMethodOrder(OrderAnnotation::class)
class UserManagementUITest : BaseUITest() {
    
    @Test
    @Order(1)
    fun `should display user list on navigation`() {
        navigateTo("users")
        waitForVaadin()
        
        val userListPage = UserListViewPageObject(driver)
        
        // Verify page loads correctly
        assertThat(driver.title).contains("User Management")
        
        // Verify grid is present and has data
        userListPage.verifyUserCount(0) // Assuming empty state initially
    }
    
    @Test
    @Order(2)
    fun `should create new user successfully`() {
        navigateTo("users")
        waitForVaadin()
        
        val userListPage = UserListViewPageObject(driver)
        val createDialog = userListPage.clickAddUser()
        
        // Fill user details
        createDialog
            .fillUserDetails("John", "Doe", "john.doe@example.com")
            .clickSave()
        
        // Verify user was created
        userListPage.verifyUserExists("john.doe@example.com")
    }
    
    @Test
    @Order(3)
    fun `should validate required fields in user creation`() {
        navigateTo("users")
        waitForVaadin()
        
        val userListPage = UserListViewPageObject(driver)
        val createDialog = userListPage.clickAddUser()
        
        // Try to save without filling required fields
        createDialog.clickSave()
        
        // Verify validation errors
        createDialog
            .verifyValidationError("first-name-field", "First name is required")
            .verifyValidationError("last-name-field", "Last name is required")
            .verifyValidationError("email-field", "Email is required")
    }
    
    @Test
    @Order(4)
    fun `should search users by name`() {
        navigateTo("users")
        waitForVaadin()
        
        val userListPage = UserListViewPageObject(driver)
        
        // Search for user
        userListPage
            .searchForUser("John")
            .verifySearchResults("John")
    }
    
    @Test
    @Order(5)
    fun `should delete user with confirmation`() {
        navigateTo("users")
        waitForVaadin()
        
        val userListPage = UserListViewPageObject(driver)
        
        // Select and delete user
        userListPage
            .selectUserByEmail("john.doe@example.com")
            .deleteSelectedUser()
        
        // Verify user was deleted
        assertThat(userListPage.verifyUserExists("john.doe@example.com")).isFalse()
    }
}
```

### Component Unit Tests
```kotlin
class UserFormComponentTest {
    
    private lateinit var userForm: UserForm
    private lateinit var mockUserService: UserService
    private lateinit var mockNotificationService: NotificationService
    
    @BeforeEach
    fun setUp() {
        mockUserService = mock()
        mockNotificationService = mock()
        userForm = UserForm(mockUserService, mockNotificationService)
    }
    
    @Test
    fun `should validate required fields`() {
        // Trigger validation
        val isValid = userForm.validateForm()
        
        assertThat(isValid).isFalse()
        assertThat(userForm.firstNameField.isInvalid).isTrue()
        assertThat(userForm.lastNameField.isInvalid).isTrue()
        assertThat(userForm.emailField.isInvalid).isTrue()
    }
    
    @Test
    fun `should validate email format`() {
        userForm.firstNameField.value = "John"
        userForm.lastNameField.value = "Doe"
        userForm.emailField.value = "invalid-email"
        
        val isValid = userForm.validateForm()
        
        assertThat(isValid).isFalse()
        assertThat(userForm.emailField.isInvalid).isTrue()
        assertThat(userForm.emailField.errorMessage).contains("Valid email")
    }
    
    @Test
    fun `should save user when form is valid`() {
        val user = User().apply {
            firstName = "John"
            lastName = "Doe"
            emailAddress = "john.doe@example.com"
        }
        
        whenever(mockUserService.createUser(any())).thenReturn(user)
        
        userForm.firstNameField.value = "John"
        userForm.lastNameField.value = "Doe"
        userForm.emailField.value = "john.doe@example.com"
        
        userForm.saveUser()
        
        verify(mockUserService).createUser(any())
        verify(mockNotificationService).showSuccess("User created successfully")
    }
    
    @Test
    fun `should handle service errors gracefully`() {
        whenever(mockUserService.createUser(any()))
            .thenThrow(DuplicateEmailException("Email already exists"))
        
        userForm.firstNameField.value = "John"
        userForm.lastNameField.value = "Doe"
        userForm.emailField.value = "john.doe@example.com"
        
        userForm.saveUser()
        
        verify(mockNotificationService).showError("Email already exists")
    }
}
```

### Cross-Browser Testing
```kotlin
@ParameterizedTest
@EnumSource(BrowserType::class)
fun `should work across different browsers`(browserType: BrowserType) {
    // Setup browser-specific driver
    driver = when (browserType) {
        BrowserType.CHROME -> {
            WebDriverManager.chromedriver().setup()
            ChromeDriver(ChromeOptions().apply {
                addArguments("--headless")
                addArguments("--no-sandbox")
            })
        }
        BrowserType.FIREFOX -> {
            WebDriverManager.firefoxdriver().setup()
            FirefoxDriver(FirefoxOptions().apply {
                addArguments("--headless")
            })
        }
        BrowserType.EDGE -> {
            WebDriverManager.edgedriver().setup()
            EdgeDriver(EdgeOptions().apply {
                addArguments("--headless")
            })
        }
    }
    
    testBench().resizeViewPortTo(1920, 1080)
    
    // Run standard test
    navigateTo("users")
    waitForVaadin()
    
    val userListPage = UserListViewPageObject(driver)
    assertThat(driver.title).contains("User Management")
}

enum class BrowserType {
    CHROME, FIREFOX, EDGE
}
```

### Performance Testing
```kotlin
@Test
fun `should load user list within performance threshold`() {
    val startTime = System.currentTimeMillis()
    
    navigateTo("users")
    waitForVaadin()
    
    val loadTime = System.currentTimeMillis() - startTime
    
    // Page should load within 3 seconds
    assertThat(loadTime).isLessThan(3000)
}

@Test
fun `should handle large datasets efficiently`() {
    // Create test data - 1000 users
    val users = (1..1000).map { i ->
        UserCreateDto("User$i", "Test$i", "user$i@test.com")
    }
    
    // Setup test data
    userService.createUsersInBatch(users)
    
    val startTime = System.currentTimeMillis()
    
    navigateTo("users")
    waitForVaadin()
    
    val loadTime = System.currentTimeMillis() - startTime
    
    // Should load even with large dataset within 5 seconds
    assertThat(loadTime).isLessThan(5000)
    
    val userListPage = UserListViewPageObject(driver)
    userListPage.verifyUserCount(1000)
}
```

### Mobile Responsive Testing
```kotlin
@Test
fun `should display correctly on mobile viewport`() {
    // Set mobile viewport
    driver.manage().window().size = Dimension(375, 667) // iPhone SE
    
    navigateTo("users")
    waitForVaadin()
    
    // Verify mobile-specific layout
    val mobileMenu = $(ButtonElement::class.java).id("mobile-menu-button")
    assertThat(mobileMenu.isDisplayed).isTrue()
    
    // Verify grid adapts to mobile
    val grid = $(GridElement::class.java).id("user-grid")
    assertThat(grid.isDisplayed).isTrue()
}

@Test
fun `should support touch interactions on mobile`() {
    driver.manage().window().size = Dimension(375, 667)
    
    navigateTo("users")
    waitForVaadin()
    
    val userListPage = UserListViewPageObject(driver)
    
    // Test touch interactions
    val addButton = $(ButtonElement::class.java).id("add-user-button")
    
    // Simulate touch tap
    Actions(driver)
        .clickAndHold(addButton)
        .pause(Duration.ofMillis(100))
        .release()
        .perform()
    
    waitForVaadin()
    
    // Verify dialog opened
    val dialog = $(DialogElement::class.java).first()
    assertThat(dialog.isDisplayed).isTrue()
}
```

## CLAUDE_CODE_COMMANDS

```bash
# Run UI tests
mvn test -Dtest="*UITest"

# Run tests with specific browser
mvn test -Dtest="*UITest" -Dwebdriver.chrome.driver=/path/to/chromedriver

# Run tests in headless mode
mvn test -Dtest="*UITest" -Dvaadin.testbench.headless=true

# Generate test reports
mvn surefire-report:report

# Run performance tests
mvn test -Dtest="*PerformanceTest" -Dvaadin.productionMode=true
```

## VALIDATION_CHECKLIST
- [ ] Page Object Pattern implemented for reusability
- [ ] Component unit tests cover validation logic
- [ ] Integration tests cover user workflows
- [ ] Cross-browser compatibility tested
- [ ] Mobile responsive behavior verified
- [ ] Performance thresholds defined and tested
- [ ] Error handling scenarios covered
- [ ] Accessibility features tested
- [ ] Test data management strategy in place
- [ ] CI/CD pipeline includes UI tests