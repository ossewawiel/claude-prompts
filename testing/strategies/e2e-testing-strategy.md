# End-to-End Testing Strategy - Claude Code Instructions

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
    testImplementation("org.seleniumhq.selenium:selenium-java:4.15.0")
    testImplementation("io.github.bonigarcia:webdrivermanager:5.6.2")
    testImplementation("org.testcontainers:junit-jupiter:1.19.3")
    testImplementation("org.testcontainers:postgresql:1.19.3")
    testImplementation("org.awaitility:awaitility:4.2.0")
    testImplementation("io.rest-assured:rest-assured:5.3.2")
    testImplementation("com.github.tomakehurst:wiremock-jre8:2.35.1")
}
```

### Test Environment Setup
```kotlin
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = [
        "spring.datasource.url=jdbc:tc:postgresql:15:///e2etest",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "spring.flyway.enabled=false",
        "vaadin.productionMode=false",
        "logging.level.org.springframework.web=INFO"
    ]
)
@Testcontainers
abstract class BaseE2ETest : TestBenchTestCase() {
    
    @LocalServerPort
    protected var port: Int = 0
    
    companion object {
        @Container
        @JvmStatic
        val postgres = PostgreSQLContainer<Nothing>("postgres:15").apply {
            withDatabaseName("e2etest")
            withUsername("test")
            withPassword("test")
        }
        
        @Container
        @JvmStatic
        val wiremock = WireMockContainer("wiremock/wiremock:2.35.0").apply {
            withExposedPorts(8080)
        }
    }
    
    @BeforeAll
    fun setupClass() {
        WebDriverManager.chromedriver().setup()
        driver = ChromeDriver(ChromeOptions().apply {
            addArguments("--headless")
            addArguments("--no-sandbox")
            addArguments("--disable-dev-shm-usage")
            addArguments("--disable-gpu")
            addArguments("--window-size=1920,1080")
            addArguments("--disable-extensions")
            addArguments("--disable-web-security")
        })
        
        testBench().resizeViewPortTo(1920, 1080)
    }
    
    @AfterAll
    fun tearDownClass() {
        driver?.quit()
    }
    
    @BeforeEach
    fun setUp() {
        // Clear database between tests
        cleanDatabase()
        
        // Setup test data
        setupTestData()
        
        // Navigate to application
        driver.get("http://localhost:$port")
        waitForApplication()
    }
    
    protected fun navigateTo(route: String) {
        driver.get("http://localhost:$port/$route")
        waitForApplication()
    }
    
    protected fun waitForApplication() {
        testBench().waitForVaadin()
        // Additional wait for any async operations
        await().atMost(Duration.ofSeconds(10))
            .until { driver.findElements(By.className("loading")).isEmpty() }
    }
    
    protected abstract fun setupTestData()
    protected abstract fun cleanDatabase()
}
```

## IMPLEMENTATION STRATEGY

### User Journey Tests
```kotlin
class UserManagementE2ETest : BaseE2ETest() {
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    override fun setupTestData() {
        // Create admin user for authentication
        val adminUser = User().apply {
            firstName = "Admin"
            lastName = "User"
            emailAddress = "admin@example.com"
            role = UserRole.ADMIN
            isActive = true
        }
        userRepository.save(adminUser)
    }
    
    override fun cleanDatabase() {
        userRepository.deleteAll()
    }
    
    @Test
    @Order(1)
    fun `complete user management workflow`() {
        // Step 1: Login as admin
        loginAsAdmin()
        
        // Step 2: Navigate to user management
        navigateToUserManagement()
        
        // Step 3: Create new user
        val newUser = createNewUser("John", "Doe", "john.doe@example.com")
        
        // Step 4: Verify user appears in list
        verifyUserInList(newUser)
        
        // Step 5: Edit user details
        val updatedUser = editUser(newUser, "Johnny", "Smith")
        
        // Step 6: Verify changes are saved
        verifyUserUpdated(updatedUser)
        
        // Step 7: Search for user
        searchForUser("Johnny")
        verifySearchResults("Johnny")
        
        // Step 8: Deactivate user
        deactivateUser(updatedUser)
        
        // Step 9: Verify user is deactivated
        verifyUserDeactivated(updatedUser)
    }
    
    private fun loginAsAdmin() {
        val loginPage = LoginPageObject(driver)
        loginPage.login("admin@example.com", "admin123")
        
        // Verify successful login
        await().atMost(Duration.ofSeconds(5))
            .until { driver.currentUrl.contains("/dashboard") }
    }
    
    private fun navigateToUserManagement() {
        val navigationMenu = NavigationMenuPageObject(driver)
        navigationMenu.clickUserManagement()
        
        await().atMost(Duration.ofSeconds(5))
            .until { driver.currentUrl.contains("/users") }
    }
    
    private fun createNewUser(firstName: String, lastName: String, email: String): TestUser {
        val userListPage = UserListPageObject(driver)
        val createDialog = userListPage.clickAddUser()
        
        createDialog.fillUserDetails(firstName, lastName, email)
        createDialog.clickSave()
        
        waitForApplication()
        
        return TestUser(firstName, lastName, email)
    }
    
    private fun verifyUserInList(user: TestUser) {
        val userListPage = UserListPageObject(driver)
        assertThat(userListPage.userExists(user.email)).isTrue()
    }
    
    private fun editUser(user: TestUser, newFirstName: String, newLastName: String): TestUser {
        val userListPage = UserListPageObject(driver)
        val editDialog = userListPage.editUser(user.email)
        
        editDialog.updateUserDetails(newFirstName, newLastName)
        editDialog.clickSave()
        
        waitForApplication()
        
        return TestUser(newFirstName, newLastName, user.email)
    }
    
    private fun verifyUserUpdated(user: TestUser) {
        val userListPage = UserListPageObject(driver)
        assertThat(userListPage.getUserDisplayName(user.email))
            .isEqualTo("${user.firstName} ${user.lastName}")
    }
    
    private fun searchForUser(searchTerm: String) {
        val userListPage = UserListPageObject(driver)
        userListPage.searchUsers(searchTerm)
        waitForApplication()
    }
    
    private fun verifySearchResults(searchTerm: String) {
        val userListPage = UserListPageObject(driver)
        val results = userListPage.getDisplayedUsers()
        assertThat(results).allMatch { user ->
            user.contains(searchTerm, ignoreCase = true)
        }
    }
    
    private fun deactivateUser(user: TestUser) {
        val userListPage = UserListPageObject(driver)
        userListPage.selectUser(user.email)
        userListPage.clickDeactivate()
        
        val confirmDialog = ConfirmDialogPageObject(driver)
        confirmDialog.confirm()
        
        waitForApplication()
    }
    
    private fun verifyUserDeactivated(user: TestUser) {
        val userListPage = UserListPageObject(driver)
        assertThat(userListPage.getUserStatus(user.email)).isEqualTo("INACTIVE")
    }
}

data class TestUser(
    val firstName: String,
    val lastName: String,
    val email: String
)
```

### Order Processing E2E Test
```kotlin
class OrderProcessingE2ETest : BaseE2ETest() {
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    @Autowired
    private lateinit var productRepository: ProductRepository
    
    override fun setupTestData() {
        // Create customer user
        val customer = User().apply {
            firstName = "Jane"
            lastName = "Customer"
            emailAddress = "jane@example.com"
            role = UserRole.CUSTOMER
            isActive = true
        }
        userRepository.save(customer)
        
        // Create test products
        val products = listOf(
            Product("Laptop", BigDecimal("999.99"), 10),
            Product("Mouse", BigDecimal("29.99"), 50),
            Product("Keyboard", BigDecimal("79.99"), 25)
        )
        productRepository.saveAll(products)
    }
    
    override fun cleanDatabase() {
        userRepository.deleteAll()
        productRepository.deleteAll()
    }
    
    @Test
    fun `complete order processing workflow`() {
        // Step 1: Login as customer
        loginAsCustomer()
        
        // Step 2: Browse products
        navigateToProductCatalog()
        
        // Step 3: Add items to cart
        addProductToCart("Laptop", 1)
        addProductToCart("Mouse", 2)
        
        // Step 4: Verify cart contents
        verifyCartContents(listOf(
            CartItem("Laptop", 1, BigDecimal("999.99")),
            CartItem("Mouse", 2, BigDecimal("59.98"))
        ))
        
        // Step 5: Proceed to checkout
        proceedToCheckout()
        
        // Step 6: Fill shipping information
        fillShippingInformation(
            address = "123 Main St",
            city = "Springfield",
            zipCode = "12345"
        )
        
        // Step 7: Select payment method
        selectPaymentMethod("credit_card")
        
        // Step 8: Place order
        val orderId = placeOrder()
        
        // Step 9: Verify order confirmation
        verifyOrderConfirmation(orderId)
        
        // Step 10: Check order in order history
        navigateToOrderHistory()
        verifyOrderInHistory(orderId)
    }
    
    private fun loginAsCustomer() {
        val loginPage = LoginPageObject(driver)
        loginPage.login("jane@example.com", "customer123")
        
        await().atMost(Duration.ofSeconds(5))
            .until { driver.currentUrl.contains("/dashboard") }
    }
    
    private fun navigateToProductCatalog() {
        val navigationMenu = NavigationMenuPageObject(driver)
        navigationMenu.clickProducts()
        
        await().atMost(Duration.ofSeconds(5))
            .until { driver.currentUrl.contains("/products") }
    }
    
    private fun addProductToCart(productName: String, quantity: Int) {
        val productCatalogPage = ProductCatalogPageObject(driver)
        productCatalogPage.addToCart(productName, quantity)
        
        waitForApplication()
        
        // Verify add to cart notification
        val notification = NotificationPageObject(driver)
        notification.verifySuccess("Product added to cart")
    }
    
    private fun verifyCartContents(expectedItems: List<CartItem>) {
        val cartPage = CartPageObject(driver)
        cartPage.openCart()
        
        expectedItems.forEach { item ->
            assertThat(cartPage.hasItem(item.productName, item.quantity)).isTrue()
            assertThat(cartPage.getItemTotal(item.productName)).isEqualTo(item.total)
        }
        
        val expectedTotal = expectedItems.sumOf { it.total }
        assertThat(cartPage.getCartTotal()).isEqualTo(expectedTotal)
    }
    
    private fun proceedToCheckout() {
        val cartPage = CartPageObject(driver)
        cartPage.clickCheckout()
        
        await().atMost(Duration.ofSeconds(5))
            .until { driver.currentUrl.contains("/checkout") }
    }
    
    private fun fillShippingInformation(address: String, city: String, zipCode: String) {
        val checkoutPage = CheckoutPageObject(driver)
        checkoutPage.fillShippingAddress(address, city, zipCode)
    }
    
    private fun selectPaymentMethod(method: String) {
        val checkoutPage = CheckoutPageObject(driver)
        checkoutPage.selectPaymentMethod(method)
    }
    
    private fun placeOrder(): String {
        val checkoutPage = CheckoutPageObject(driver)
        checkoutPage.clickPlaceOrder()
        
        waitForApplication()
        
        // Wait for order confirmation page
        await().atMost(Duration.ofSeconds(10))
            .until { driver.currentUrl.contains("/order-confirmation") }
        
        val confirmationPage = OrderConfirmationPageObject(driver)
        return confirmationPage.getOrderId()
    }
    
    private fun verifyOrderConfirmation(orderId: String) {
        val confirmationPage = OrderConfirmationPageObject(driver)
        assertThat(confirmationPage.getOrderId()).isEqualTo(orderId)
        assertThat(confirmationPage.getStatus()).isEqualTo("CONFIRMED")
    }
    
    private fun navigateToOrderHistory() {
        val navigationMenu = NavigationMenuPageObject(driver)
        navigationMenu.clickOrderHistory()
        
        await().atMost(Duration.ofSeconds(5))
            .until { driver.currentUrl.contains("/orders") }
    }
    
    private fun verifyOrderInHistory(orderId: String) {
        val orderHistoryPage = OrderHistoryPageObject(driver)
        assertThat(orderHistoryPage.hasOrder(orderId)).isTrue()
        assertThat(orderHistoryPage.getOrderStatus(orderId)).isEqualTo("CONFIRMED")
    }
}

data class CartItem(
    val productName: String,
    val quantity: Int,
    val total: BigDecimal
)
```

### Cross-Browser E2E Tests
```kotlin
@ParameterizedTest
@EnumSource(BrowserType::class)
fun `user workflow should work across browsers`(browserType: BrowserType) {
    // Setup browser-specific driver
    setupBrowserDriver(browserType)
    
    try {
        // Run critical user journey
        loginAsUser()
        performCoreOperations()
        verifyResults()
    } finally {
        driver?.quit()
    }
}

private fun setupBrowserDriver(browserType: BrowserType) {
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
}
```

### Performance E2E Tests
```kotlin
@Test
fun `application should load within performance thresholds`() {
    val metrics = mutableMapOf<String, Long>()
    
    // Test login performance
    val loginStart = System.currentTimeMillis()
    loginAsUser()
    metrics["login_time"] = System.currentTimeMillis() - loginStart
    
    // Test navigation performance
    val navStart = System.currentTimeMillis()
    navigateToUserManagement()
    metrics["navigation_time"] = System.currentTimeMillis() - navStart
    
    // Test data loading performance
    val dataStart = System.currentTimeMillis()
    loadUserList()
    metrics["data_load_time"] = System.currentTimeMillis() - dataStart
    
    // Verify performance thresholds
    assertThat(metrics["login_time"]).isLessThan(3000) // 3 seconds
    assertThat(metrics["navigation_time"]).isLessThan(2000) // 2 seconds
    assertThat(metrics["data_load_time"]).isLessThan(5000) // 5 seconds
    
    println("Performance metrics: $metrics")
}

@Test
fun `application should handle concurrent users`() {
    val numberOfUsers = 5
    val executor = Executors.newFixedThreadPool(numberOfUsers)
    val futures = mutableListOf<Future<Boolean>>()
    
    repeat(numberOfUsers) { userIndex ->
        val future = executor.submit<Boolean> {
            try {
                // Each user performs a complete workflow
                setupBrowserDriver(BrowserType.CHROME)
                loginAsUser("user$userIndex@example.com")
                performUserOperations()
                logoutUser()
                true
            } catch (e: Exception) {
                e.printStackTrace()
                false
            } finally {
                driver?.quit()
            }
        }
        futures.add(future)
    }
    
    // Verify all users completed successfully
    val results = futures.map { it.get() }
    assertThat(results).allMatch { it }
    
    executor.shutdown()
}
```

### Error Scenario E2E Tests
```kotlin
@Test
fun `should handle service unavailability gracefully`() {
    // Setup WireMock to simulate service failure
    wiremock.stubFor(
        get(urlPathMatching("/api/.*"))
            .willReturn(
                aResponse()
                    .withStatus(503)
                    .withBody("Service Unavailable")
            )
    )
    
    loginAsUser()
    navigateToUserManagement()
    
    // Verify error handling
    val errorPage = ErrorPageObject(driver)
    assertThat(errorPage.isDisplayed()).isTrue()
    assertThat(errorPage.getErrorMessage()).contains("Service temporarily unavailable")
    
    // Verify retry mechanism
    errorPage.clickRetry()
    waitForApplication()
}

@Test
fun `should handle network timeouts appropriately`() {
    // Setup WireMock to simulate slow response
    wiremock.stubFor(
        get(urlPathMatching("/api/users"))
            .willReturn(
                aResponse()
                    .withFixedDelay(30000) // 30 second delay
                    .withStatus(200)
            )
    )
    
    loginAsUser()
    navigateToUserManagement()
    
    // Verify timeout handling
    await().atMost(Duration.ofSeconds(35))
        .until {
            val errorMessage = $(SpanElement::class.java).id("error-message")
            errorMessage.isDisplayed && errorMessage.text.contains("timeout")
        }
}
```

## CLAUDE_CODE_COMMANDS

```bash
# Run E2E tests
mvn test -Dtest="*E2ETest"

# Run with specific browser
mvn test -Dtest="*E2ETest" -Dwebdriver.chrome.driver=/path/to/chromedriver

# Run cross-browser tests
mvn test -Dtest="*E2ETest" -Dcross.browser.test=true

# Run performance E2E tests
mvn test -Dtest="*PerformanceE2ETest"

# Run E2E tests with video recording
mvn test -Dtest="*E2ETest" -Dtestcontainers.vnc.record=true

# Generate E2E test report
mvn surefire-report:report -Dtest="*E2ETest"
```

## VALIDATION_CHECKLIST
- [ ] Complete user journeys tested end-to-end
- [ ] Cross-browser compatibility verified
- [ ] Performance thresholds defined and tested
- [ ] Error scenarios and edge cases covered
- [ ] Authentication and authorization flows tested
- [ ] Data persistence verified across workflows
- [ ] External service integrations tested
- [ ] Mobile responsive behavior verified
- [ ] Concurrent user scenarios tested
- [ ] Test data management strategy implemented