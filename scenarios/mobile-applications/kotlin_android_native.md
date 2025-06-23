# Kotlin Android Native Application - Claude Code Instructions

## CONTEXT
**Project Type**: mobile-app
**Complexity**: complex
**Timeline**: production
**Architecture**: Native Android application with modern Kotlin and Jetpack Compose
**Last Updated**: 2025-06-18
**Template Version**: 2.3.1

## MANDATORY REQUIREMENTS

### Technology Stack
- **Primary Language**: Kotlin 2.0.x
- **Android Platform**: Android API 24+ (Android 7.0) to API 35+ (Android 15)
- **UI Framework**: Jetpack Compose 1.7.x with Material Design 3
- **Architecture**: MVVM with Repository Pattern
- **Build Tool**: Gradle 8.8.x with Kotlin DSL and Version Catalogs
- **Dependency Injection**: Hilt 2.52.x
- **Database**: Room 2.6.x with Kotlin Coroutines
- **Networking**: Retrofit 2.11.x + OkHttp 4.12.x
- **Image Loading**: Coil 2.7.x
- **Navigation**: Navigation Compose 2.8.x
- **State Management**: ViewModel + StateFlow + Compose State
- **Background Tasks**: WorkManager 2.9.x
- **Testing**: JUnit 5 + Espresso + Compose Testing
- **Code Quality**: Detekt 1.23.x + ktlint 1.3.x

### Project Structure
```
{{project_name}}/
├── app/
│   ├── src/
│   │   ├── main/
│   │   │   ├── kotlin/
│   │   │   │   └── {{base_package}}/
│   │   │   │       ├── MyApplication.kt
│   │   │   │       ├── MainActivity.kt
│   │   │   │       ├── di/
│   │   │   │       │   ├── DatabaseModule.kt
│   │   │   │       │   ├── NetworkModule.kt
│   │   │   │       │   ├── RepositoryModule.kt
│   │   │   │       │   └── ViewModelModule.kt
│   │   │   │       ├── data/
│   │   │   │       │   ├── local/
│   │   │   │       │   │   ├── database/
│   │   │   │       │   │   │   ├── AppDatabase.kt
│   │   │   │       │   │   │   ├── DatabaseMigrations.kt
│   │   │   │       │   │   │   └── entity/
│   │   │   │       │   │   │       ├── UserEntity.kt
│   │   │   │       │   │   │       ├── ProductEntity.kt
│   │   │   │       │   │   │       ├── OrderEntity.kt
│   │   │   │       │   │   │       └── CategoryEntity.kt
│   │   │   │       │   │   ├── dao/
│   │   │   │       │   │   │   ├── UserDao.kt
│   │   │   │       │   │   │   ├── ProductDao.kt
│   │   │   │       │   │   │   ├── OrderDao.kt
│   │   │   │       │   │   │   └── CategoryDao.kt
│   │   │   │       │   │   ├── preferences/
│   │   │   │       │   │   │   ├── UserPreferences.kt
│   │   │   │       │   │   │   ├── AppPreferences.kt
│   │   │   │       │   │   │   └── SecurityPreferences.kt
│   │   │   │       │   │   └── cache/
│   │   │   │       │   │       ├── CacheManager.kt
│   │   │   │       │   │       └── CachePolicy.kt
│   │   │   │       │   ├── remote/
│   │   │   │       │   │   ├── api/
│   │   │   │       │   │   │   ├── AuthApiService.kt
│   │   │   │       │   │   │   ├── UserApiService.kt
│   │   │   │       │   │   │   ├── ProductApiService.kt
│   │   │   │       │   │   │   └── OrderApiService.kt
│   │   │   │       │   │   ├── dto/
│   │   │   │       │   │   │   ├── request/
│   │   │   │       │   │   │   │   ├── LoginRequest.kt
│   │   │   │       │   │   │   │   ├── RegisterRequest.kt
│   │   │   │       │   │   │   │   ├── CreateOrderRequest.kt
│   │   │   │       │   │   │   │   └── UpdateProfileRequest.kt
│   │   │   │       │   │   │   ├── response/
│   │   │   │       │   │   │   │   ├── AuthResponse.kt
│   │   │   │       │   │   │   │   ├── UserResponse.kt
│   │   │   │       │   │   │   │   ├── ProductResponse.kt
│   │   │   │       │   │   │   │   ├── OrderResponse.kt
│   │   │   │       │   │   │   │   └── ApiResponse.kt
│   │   │   │       │   │   │   └── common/
│   │   │   │       │   │   │       ├── ErrorResponse.kt
│   │   │   │       │   │   │       ├── PaginationResponse.kt
│   │   │   │       │   │   │       └── MetadataResponse.kt
│   │   │   │       │   │   ├── interceptor/
│   │   │   │       │   │   │   ├── AuthInterceptor.kt
│   │   │   │       │   │   │   ├── NetworkInterceptor.kt
│   │   │   │       │   │   │   ├── LoggingInterceptor.kt
│   │   │   │       │   │   │   └── RetryInterceptor.kt
│   │   │   │       │   │   └── adapter/
│   │   │   │       │   │       ├── NetworkResultCallAdapter.kt
│   │   │   │       │   │       └── ErrorHandlingAdapter.kt
│   │   │   │       │   ├── repository/
│   │   │   │       │   │   ├── AuthRepository.kt
│   │   │   │       │   │   ├── UserRepository.kt
│   │   │   │       │   │   ├── ProductRepository.kt
│   │   │   │       │   │   ├── OrderRepository.kt
│   │   │   │       │   │   └── impl/
│   │   │   │       │   │       ├── AuthRepositoryImpl.kt
│   │   │   │       │   │       ├── UserRepositoryImpl.kt
│   │   │   │       │   │       ├── ProductRepositoryImpl.kt
│   │   │   │       │   │       └── OrderRepositoryImpl.kt
│   │   │   │       │   ├── mapper/
│   │   │   │       │   │   ├── UserMapper.kt
│   │   │   │       │   │   ├── ProductMapper.kt
│   │   │   │       │   │   ├── OrderMapper.kt
│   │   │   │       │   │   └── BaseMapper.kt
│   │   │   │       │   └── datasource/
│   │   │   │       │       ├── LocalDataSource.kt
│   │   │   │       │       ├── RemoteDataSource.kt
│   │   │   │       │       └── CacheDataSource.kt
│   │   │   │       ├── domain/
│   │   │   │       │   ├── model/
│   │   │   │       │   │   ├── User.kt
│   │   │   │       │   │   ├── Product.kt
│   │   │   │       │   │   ├── Order.kt
│   │   │   │       │   │   ├── Category.kt
│   │   │   │       │   │   ├── Cart.kt
│   │   │   │       │   │   └── common/
│   │   │   │       │   │       ├── Result.kt
│   │   │   │       │   │       ├── Resource.kt
│   │   │   │       │   │       ├── UiState.kt
│   │   │   │       │   │       └── NetworkResult.kt
│   │   │   │       │   ├── usecase/
│   │   │   │       │   │   ├── auth/
│   │   │   │       │   │   │   ├── LoginUseCase.kt
│   │   │   │       │   │   │   ├── LogoutUseCase.kt
│   │   │   │       │   │   │   ├── RegisterUseCase.kt
│   │   │   │       │   │   │   └── RefreshTokenUseCase.kt
│   │   │   │       │   │   ├── user/
│   │   │   │       │   │   │   ├── GetUserProfileUseCase.kt
│   │   │   │       │   │   │   ├── UpdateUserProfileUseCase.kt
│   │   │   │       │   │   │   └── ChangePasswordUseCase.kt
│   │   │   │       │   │   ├── product/
│   │   │   │       │   │   │   ├── GetProductsUseCase.kt
│   │   │   │       │   │   │   ├── GetProductDetailsUseCase.kt
│   │   │   │       │   │   │   ├── SearchProductsUseCase.kt
│   │   │   │       │   │   │   └── GetCategoriesUseCase.kt
│   │   │   │       │   │   ├── cart/
│   │   │   │       │   │   │   ├── AddToCartUseCase.kt
│   │   │   │       │   │   │   ├── RemoveFromCartUseCase.kt
│   │   │   │       │   │   │   ├── UpdateCartItemUseCase.kt
│   │   │   │       │   │   │   └── GetCartUseCase.kt
│   │   │   │       │   │   └── order/
│   │   │   │       │   │       ├── CreateOrderUseCase.kt
│   │   │   │       │   │       ├── GetOrdersUseCase.kt
│   │   │   │       │   │       ├── GetOrderDetailsUseCase.kt
│   │   │   │       │   │       └── CancelOrderUseCase.kt
│   │   │   │       │   └── repository/
│   │   │   │       │       ├── AuthRepository.kt
│   │   │   │       │       ├── UserRepository.kt
│   │   │   │       │       ├── ProductRepository.kt
│   │   │   │       │       └── OrderRepository.kt
│   │   │   │       ├── presentation/
│   │   │   │       │   ├── navigation/
│   │   │   │       │   │   ├── AppNavigation.kt
│   │   │   │       │   │   ├── NavigationDestinations.kt
│   │   │   │       │   │   ├── NavigationArgs.kt
│   │   │   │       │   │   └── BottomNavigation.kt
│   │   │   │       │   ├── theme/
│   │   │   │       │   │   ├── Color.kt
│   │   │   │       │   │   ├── Type.kt
│   │   │   │       │   │   ├── Theme.kt
│   │   │   │       │   │   ├── Shape.kt
│   │   │   │       │   │   └── Dimension.kt
│   │   │   │       │   ├── component/
│   │   │   │       │   │   ├── common/
│   │   │   │       │   │   │   ├── AppButton.kt
│   │   │   │       │   │   │   ├── AppTextField.kt
│   │   │   │       │   │   │   ├── AppCard.kt
│   │   │   │       │   │   │   ├── AppDialog.kt
│   │   │   │       │   │   │   ├── AppToolbar.kt
│   │   │   │       │   │   │   ├── LoadingIndicator.kt
│   │   │   │       │   │   │   ├── ErrorMessage.kt
│   │   │   │       │   │   │   └── EmptyState.kt
│   │   │   │       │   │   ├── auth/
│   │   │   │       │   │   │   ├── LoginForm.kt
│   │   │   │       │   │   │   ├── RegisterForm.kt
│   │   │   │       │   │   │   └── PasswordField.kt
│   │   │   │       │   │   ├── product/
│   │   │   │       │   │   │   ├── ProductCard.kt
│   │   │   │       │   │   │   ├── ProductGrid.kt
│   │   │   │       │   │   │   ├── ProductList.kt
│   │   │   │       │   │   │   ├── CategoryChip.kt
│   │   │   │       │   │   │   └── SearchBar.kt
│   │   │   │       │   │   ├── cart/
│   │   │   │       │   │   │   ├── CartItem.kt
│   │   │   │       │   │   │   ├── CartSummary.kt
│   │   │   │       │   │   │   └── QuantitySelector.kt
│   │   │   │       │   │   └── order/
│   │   │   │       │   │       ├── OrderItem.kt
│   │   │   │       │   │       ├── OrderStatus.kt
│   │   │   │       │   │       └── OrderSummary.kt
│   │   │   │       │   ├── screen/
│   │   │   │       │   │   ├── auth/
│   │   │   │       │   │   │   ├── LoginScreen.kt
│   │   │   │       │   │   │   ├── RegisterScreen.kt
│   │   │   │       │   │   │   ├── ForgotPasswordScreen.kt
│   │   │   │       │   │   │   └── SplashScreen.kt
│   │   │   │       │   │   ├── main/
│   │   │   │       │   │   │   ├── MainScreen.kt
│   │   │   │       │   │   │   ├── HomeScreen.kt
│   │   │   │       │   │   │   ├── SearchScreen.kt
│   │   │   │       │   │   │   └── ProfileScreen.kt
│   │   │   │       │   │   ├── product/
│   │   │   │       │   │   │   ├── ProductListScreen.kt
│   │   │   │       │   │   │   ├── ProductDetailScreen.kt
│   │   │   │       │   │   │   └── CategoryScreen.kt
│   │   │   │       │   │   ├── cart/
│   │   │   │       │   │   │   ├── CartScreen.kt
│   │   │   │       │   │   │   └── CheckoutScreen.kt
│   │   │   │       │   │   ├── order/
│   │   │   │       │   │   │   ├── OrderListScreen.kt
│   │   │   │       │   │   │   ├── OrderDetailScreen.kt
│   │   │   │       │   │   │   └── OrderTrackingScreen.kt
│   │   │   │       │   │   └── settings/
│   │   │   │       │   │       ├── SettingsScreen.kt
│   │   │   │       │   │       ├── EditProfileScreen.kt
│   │   │   │       │   │       ├── ChangePasswordScreen.kt
│   │   │   │       │   │       └── NotificationSettingsScreen.kt
│   │   │   │       │   └── viewmodel/
│   │   │   │       │       ├── auth/
│   │   │   │       │       │   ├── LoginViewModel.kt
│   │   │   │       │       │   ├── RegisterViewModel.kt
│   │   │   │       │       │   └── AuthState.kt
│   │   │   │       │       ├── main/
│   │   │   │       │       │   ├── MainViewModel.kt
│   │   │   │       │       │   ├── HomeViewModel.kt
│   │   │   │       │       │   └── ProfileViewModel.kt
│   │   │   │       │       ├── product/
│   │   │   │       │       │   ├── ProductListViewModel.kt
│   │   │   │       │       │   ├── ProductDetailViewModel.kt
│   │   │   │       │       │   └── SearchViewModel.kt
│   │   │   │       │       ├── cart/
│   │   │   │       │       │   ├── CartViewModel.kt
│   │   │   │       │       │   └── CheckoutViewModel.kt
│   │   │   │       │       └── order/
│   │   │   │       │           ├── OrderListViewModel.kt
│   │   │   │       │           └── OrderDetailViewModel.kt
│   │   │   │       ├── util/
│   │   │   │       │   ├── extension/
│   │   │   │       │   │   ├── StringExtensions.kt
│   │   │   │       │   │   ├── ContextExtensions.kt
│   │   │   │       │   │   ├── ViewExtensions.kt
│   │   │   │       │   │   ├── FlowExtensions.kt
│   │   │   │       │   │   └── ComposeExtensions.kt
│   │   │   │       │   ├── constant/
│   │   │   │       │   │   ├── Constants.kt
│   │   │   │       │   │   ├── ApiConstants.kt
│   │   │   │       │   │   ├── DatabaseConstants.kt
│   │   │   │       │   │   └── ValidationConstants.kt
│   │   │   │       │   ├── helper/
│   │   │   │       │   │   ├── ValidationHelper.kt
│   │   │   │       │   │   ├── DateTimeHelper.kt
│   │   │   │       │   │   ├── CurrencyHelper.kt
│   │   │   │       │   │   ├── ImageHelper.kt
│   │   │   │       │   │   └── BiometricHelper.kt
│   │   │   │       │   ├── manager/
│   │   │   │       │   │   ├── SessionManager.kt
│   │   │   │       │   │   ├── NetworkManager.kt
│   │   │   │       │   │   ├── NotificationManager.kt
│   │   │   │       │   │   ├── PermissionManager.kt
│   │   │   │       │   │   └── CrashReportingManager.kt
│   │   │   │       │   └── worker/
│   │   │   │       │       ├── SyncDataWorker.kt
│   │   │   │       │       ├── CacheCleanupWorker.kt
│   │   │   │       │       ├── NotificationWorker.kt
│   │   │   │       │       └── UploadWorker.kt
│   │   │   │       └── security/
│   │   │   │           ├── BiometricAuthenticator.kt
│   │   │   │           ├── KeystoreManager.kt
│   │   │   │           ├── EncryptionHelper.kt
│   │   │   │           ├── CertificatePinner.kt
│   │   │   │           └── SecurityValidation.kt
│   │   │   ├── res/
│   │   │   │   ├── drawable/
│   │   │   │   │   ├── ic_launcher_background.xml
│   │   │   │   │   ├── ic_launcher_foreground.xml
│   │   │   │   │   ├── splash_background.xml
│   │   │   │   │   └── icons/
│   │   │   │   │       ├── ic_home.xml
│   │   │   │   │       ├── ic_search.xml
│   │   │   │   │       ├── ic_cart.xml
│   │   │   │   │       ├── ic_profile.xml
│   │   │   │   │       └── ic_settings.xml
│   │   │   │   ├── values/
│   │   │   │   │   ├── colors.xml
│   │   │   │   │   ├── strings.xml
│   │   │   │   │   ├── dimens.xml
│   │   │   │   │   ├── styles.xml
│   │   │   │   │   └── themes.xml
│   │   │   │   ├── values-night/
│   │   │   │   │   ├── colors.xml
│   │   │   │   │   └── themes.xml
│   │   │   │   ├── values-v31/
│   │   │   │   │   └── themes.xml
│   │   │   │   ├── layout/
│   │   │   │   │   ├── activity_main.xml
│   │   │   │   │   └── splash_screen.xml
│   │   │   │   ├── mipmap-anydpi-v26/
│   │   │   │   │   ├── ic_launcher.xml
│   │   │   │   │   └── ic_launcher_round.xml
│   │   │   │   ├── mipmap-hdpi/
│   │   │   │   ├── mipmap-mdpi/
│   │   │   │   ├── mipmap-xhdpi/
│   │   │   │   ├── mipmap-xxhdpi/
│   │   │   │   ├── mipmap-xxxhdpi/
│   │   │   │   ├── xml/
│   │   │   │   │   ├── backup_rules.xml
│   │   │   │   │   ├── data_extraction_rules.xml
│   │   │   │   │   └── network_security_config.xml
│   │   │   │   └── raw/
│   │   │   │       └── certificates/
│   │   │   └── AndroidManifest.xml
│   │   ├── debug/
│   │   │   ├── kotlin/
│   │   │   │   └── {{base_package}}/
│   │   │   │       └── debug/
│   │   │   │           ├── DebugApplication.kt
│   │   │   │           ├── DebugInterceptor.kt
│   │   │   │           └── DebugTools.kt
│   │   │   └── res/
│   │   │       ├── values/
│   │   │       │   └── strings.xml
│   │   │       └── xml/
│   │   │           └── debug_network_security_config.xml
│   │   ├── test/
│   │   │   └── kotlin/
│   │   │       └── {{base_package}}/
│   │   │           ├── repository/
│   │   │           │   ├── AuthRepositoryTest.kt
│   │   │           │   ├── UserRepositoryTest.kt
│   │   │           │   ├── ProductRepositoryTest.kt
│   │   │           │   └── OrderRepositoryTest.kt
│   │   │           ├── usecase/
│   │   │           │   ├── LoginUseCaseTest.kt
│   │   │           │   ├── GetProductsUseCaseTest.kt
│   │   │           │   └── CreateOrderUseCaseTest.kt
│   │   │           ├── viewmodel/
│   │   │           │   ├── LoginViewModelTest.kt
│   │   │           │   ├── ProductListViewModelTest.kt
│   │   │           │   └── CartViewModelTest.kt
│   │   │           ├── util/
│   │   │           │   ├── TestDataFactory.kt
│   │   │           │   ├── TestCoroutineRule.kt
│   │   │           │   └── MockWebServerRule.kt
│   │   │           └── mapper/
│   │   │               ├── UserMapperTest.kt
│   │   │               └── ProductMapperTest.kt
│   │   └── androidTest/
│   │       └── kotlin/
│   │           └── {{base_package}}/
│   │               ├── ui/
│   │               │   ├── auth/
│   │               │   │   ├── LoginScreenTest.kt
│   │               │   │   └── RegisterScreenTest.kt
│   │               │   ├── product/
│   │               │   │   ├── ProductListScreenTest.kt
│   │               │   │   └── ProductDetailScreenTest.kt
│   │               │   └── cart/
│   │               │       ├── CartScreenTest.kt
│   │               │       └── CheckoutScreenTest.kt
│   │               ├── database/
│   │               │   ├── AppDatabaseTest.kt
│   │               │   ├── UserDaoTest.kt
│   │               │   ├── ProductDaoTest.kt
│   │               │   └── OrderDaoTest.kt
│   │               ├── navigation/
│   │               │   └── NavigationTest.kt
│   │               └── util/
│   │                   ├── ComposeTestRule.kt
│   │                   ├── HiltTestRunner.kt
│   │                   └── TestApplication.kt
│   ├── proguard/
│   │   ├── proguard-rules.pro
│   │   ├── consumer-rules.pro
│   │   └── proguard-android-optimize.txt
│   └── build.gradle.kts
├── gradle/
│   ├── libs.versions.toml
│   └── wrapper/
│       ├── gradle-wrapper.jar
│       └── gradle-wrapper.properties
├── buildSrc/
│   ├── src/main/kotlin/
│   │   ├── BuildConfig.kt
│   │   ├── Dependencies.kt
│   │   └── Versions.kt
│   └── build.gradle.kts
├── scripts/
│   ├── setup.sh
│   ├── quality-check.sh
│   ├── test.sh
│   └── release.sh
├── docs/
│   ├── architecture.md
│   ├── setup.md
│   ├── testing.md
│   ├── deployment.md
│   └── api-integration.md
├── .github/
│   └── workflows/
│       ├── ci.yml
│       ├── release.yml
│       └── quality-check.yml
├── build.gradle.kts
├── settings.gradle.kts
├── gradle.properties
├── local.properties.template
├── .gitignore
├── .editorconfig
├── detekt.yml
├── ktlint.yml
├── README.md
├── CHANGELOG.md
└── LICENSE
```

### Documentation Sources
- **Android Developers**: https://developer.android.com/
- **Kotlin Documentation**: https://kotlinlang.org/docs/android-overview.html
- **Jetpack Compose**: https://developer.android.com/jetpack/compose
- **Material Design 3**: https://m3.material.io/
- **Android Architecture**: https://developer.android.com/topic/architecture
- **Room Database**: https://developer.android.com/training/data-storage/room
- **Retrofit**: https://square.github.io/retrofit/
- **Hilt Dependency Injection**: https://dagger.dev/hilt/
- **WorkManager**: https://developer.android.com/topic/libraries/architecture/workmanager

## STRICT GUIDELINES

### Code Standards
- **Kotlin Style**: Follow Kotlin Coding Conventions and Android ktlint rules
- **Android Guidelines**: Follow Android Code Style Guidelines
- **Architecture**: MVVM with Repository pattern and Use Cases
- **Dependency Injection**: Use Hilt for all dependency injection
- **Database**: Use Room for local data storage with proper migrations
- **Networking**: Use Retrofit with OkHttp for API calls
- **UI**: Use Jetpack Compose with Material Design 3 components
- **Naming Conventions**:
  - Activities: PascalCase with 'Activity' suffix (MainActivity, LoginActivity)
  - Fragments: PascalCase with 'Fragment' suffix (UserFragment, ProductFragment)
  - ViewModels: PascalCase with 'ViewModel' suffix (LoginViewModel, ProductListViewModel)
  - Repositories: PascalCase with 'Repository' suffix (UserRepository, ProductRepository)
  - Use Cases: PascalCase with 'UseCase' suffix (GetProductsUseCase, LoginUseCase)
  - Composables: PascalCase (LoginScreen, ProductCard, AppButton)
  - Database entities: PascalCase with 'Entity' suffix (UserEntity, ProductEntity)
  - Data Transfer Objects: PascalCase with appropriate suffix (UserResponse, LoginRequest)
  - Constants: UPPER_SNAKE_CASE in companion objects
  - Resources: snake_case (activity_main, ic_launcher, color_primary)
  - Package names: lowercase with dots (com.company.app.presentation.screen)

### Architecture Rules
- **Clean Architecture**: Separate data, domain, and presentation layers
- **Single Responsibility**: Each class serves one primary purpose
- **Dependency Direction**: Dependencies point inward (UI → Domain → Data)
- **Repository Pattern**: Abstract data sources behind repository interfaces
- **Use Case Pattern**: Encapsulate business logic in specific use cases
- **MVVM Pattern**: ViewModels manage UI state and business logic
- **State Management**: Use StateFlow and Compose state for reactive UI
- **Error Handling**: Consistent error handling with sealed Result classes

### Android Best Practices
- **Lifecycle Awareness**: Use lifecycle-aware components
- **Memory Management**: Proper cleanup of resources and observers
- **Background Processing**: Use WorkManager for background tasks
- **Security**: Implement proper certificate pinning and data encryption
- **Performance**: Optimize for smooth 60fps UI and efficient memory usage
- **Accessibility**: Support TalkBack and accessibility services
- **Internationalization**: Support multiple languages and regions
- **Testing**: Comprehensive unit, integration, and UI tests

## TESTING REQUIREMENTS

### Unit Tests (90% coverage minimum)
- All ViewModel business logic and state management
- All Repository implementations with mocked data sources
- All Use Cases with domain logic validation
- All data mappers and transformations
- All utility functions and extension methods
- All validation logic and input sanitization
- All network and database error handling scenarios

### Integration Tests
- Room database operations with migrations testing
- Repository integration with local and remote data sources
- Network API integration with MockWebServer
- Hilt dependency injection module testing
- WorkManager background task execution
- SharedPreferences and DataStore operations
- File I/O and cache management testing

### UI Tests (Critical flows only)
- User authentication flow (login, register, logout)
- Product browsing and search functionality
- Shopping cart operations (add, remove, update quantities)
- Checkout and payment flow
- User profile management
- Navigation between screens
- Error states and offline scenarios
- Accessibility testing with TalkBack

### Performance Tests
- UI rendering performance (60fps target)
- Memory usage during heavy operations
- Network request batching and caching efficiency
- Database query performance with large datasets
- Image loading and caching performance
- Background task execution efficiency

## SECURITY PRACTICES

### Data Protection
- **Local Storage Encryption**: Encrypt sensitive data in Room database
- **Keystore Integration**: Use Android Keystore for secure key management
- **Certificate Pinning**: Pin SSL certificates for API endpoints
- **Network Security**: Implement network security config with HTTPS only
- **Biometric Authentication**: Support fingerprint and face authentication
- **Session Management**: Secure token storage and automatic logout
- **Input Validation**: Validate and sanitize all user inputs
- **ProGuard/R8**: Enable code obfuscation for release builds

### API Security
- **JWT Token Management**: Secure token storage with automatic refresh
- **API Key Protection**: Store API keys securely, not in source code
- **Request Signing**: Sign API requests for additional security
- **Rate Limiting**: Implement client-side rate limiting
- **CORS Validation**: Validate API responses and origins
- **Error Handling**: Avoid exposing sensitive information in error messages

### App Security
- **Root Detection**: Detect and handle rooted devices appropriately
- **Debugger Detection**: Prevent debugging in production builds
- **Screenshot Prevention**: Disable screenshots in sensitive screens
- **App Integrity**: Verify app signature and integrity
- **Runtime Security**: Monitor for runtime manipulation attempts

## IMPLEMENTATION STRATEGY

### Phase 1: Project Foundation (Week 1)
- [ ] Set up Android project with Kotlin and Gradle Kotlin DSL
- [ ] Configure build.gradle.kts with version catalogs and all dependencies
- [ ] Set up Hilt dependency injection with application and activity modules
- [ ] Create base project structure with proper package organization
- [ ] Implement Application class with Hilt, logging, and crash reporting
- [ ] Set up Jetpack Compose with Material Design 3 theme
- [ ] Configure ProGuard/R8 rules for release builds
- [ ] Set up code quality tools (Detekt, ktlint, lint)
- [ ] Create CI/CD pipeline with GitHub Actions
- [ ] Configure network security and certificate pinning

### Phase 2: Core Infrastructure (Week 2)
- [ ] Implement Room database with entities, DAOs, and migrations
- [ ] Set up Retrofit with OkHttp interceptors and error handling
- [ ] Create repository pattern with local and remote data sources
- [ ] Implement data mappers between DTOs, entities, and domain models
- [ ] Set up SharedPreferences and DataStore for app settings
- [ ] Create base ViewModels with common functionality
- [ ] Implement navigation with Navigation Compose
- [ ] Set up WorkManager for background tasks
- [ ] Create common UI components and theme system
- [ ] Implement logging and crash reporting

### Phase 3: Authentication System (Week 3)
- [ ] Design and implement authentication screens (Login, Register, Forgot Password)
- [ ] Create authentication ViewModels with state management
- [ ] Implement JWT token handling with automatic refresh
- [ ] Set up biometric authentication for app security
- [ ] Create session management and automatic logout
- [ ] Implement deep linking for authentication flows
- [ ] Add form validation and error handling
- [ ] Create onboarding screens for new users
- [ ] Implement secure token storage with Keystore
- [ ] Add social authentication options (Google, Facebook)

### Phase 4: Core Application Features (Week 4-6)
- [ ] Implement home screen with featured content and navigation
- [ ] Create product listing with categories, search, and filtering
- [ ] Build product detail screen with images, descriptions, and reviews
- [ ] Implement shopping cart functionality with persistence
- [ ] Create user profile management with edit capabilities
- [ ] Add favorites/wishlist functionality
- [ ] Implement order history and tracking
- [ ] Create settings screen with preferences and notifications
- [ ] Add offline support with data synchronization
- [ ] Implement push notifications with Firebase

### Phase 5: Advanced Features (Week 7-8)
- [ ] Add advanced search with filters and sorting options
- [ ] Implement image viewing with zoom and gallery
- [ ] Create checkout flow with payment integration
- [ ] Add order tracking with real-time updates
- [ ] Implement review and rating system
- [ ] Create admin features for content management
- [ ] Add analytics tracking for user behavior
- [ ] Implement A/B testing framework
- [ ] Create accessibility features and optimizations
- [ ] Add internationalization for multiple languages

### Phase 6: Testing & Quality Assurance (Week 9)
- [ ] Write comprehensive unit tests for all business logic
- [ ] Create integration tests for database and network operations
- [ ] Implement UI tests for critical user flows
- [ ] Add performance testing and optimization
- [ ] Conduct security testing and vulnerability assessment
- [ ] Perform accessibility testing with various devices
- [ ] Test on different Android versions and screen sizes
- [ ] Create automated testing pipeline
- [ ] Conduct user acceptance testing
- [ ] Optimize for app store guidelines compliance

### Phase 7: Performance & Security Optimization (Week 10)
- [ ] Optimize app startup time and memory usage
- [ ] Implement lazy loading and pagination
- [ ] Add image compression and caching optimizations
- [ ] Optimize database queries and indexing
- [ ] Implement proper error boundary handling
- [ ] Add security hardening measures
- [ ] Optimize network requests and caching
- [ ] Create performance monitoring and reporting
- [ ] Implement crash reporting and analytics
- [ ] Prepare for production release

## CLAUDE_CODE_COMMANDS

### Initial Setup
```bash
# Create Android project
mkdir {{project_name}}
cd {{project_name}}

# Initialize with Android Gradle Plugin
# (This would typically be done through Android Studio)
# Create basic structure manually or use Android Studio template
```

### Build Configuration (app/build.gradle.kts)
```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("kotlin-kapt")
    id("dagger.hilt.android.plugin")
    id("kotlin-parcelize")
    id("androidx.navigation.safeargs.kotlin")
    id("com.google.devtools.ksp")
    id("io.gitlab.arturbosch.detekt")
    id("org.jlleitschuh.gradle.ktlint")
}

android {
    namespace = "{{base_package}}"
    compileSdk = 35

    defaultConfig {
        applicationId = "{{base_package}}"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"

        testInstrumentationRunner = "{{base_package}}.util.HiltTestRunner"
        vectorDrawables.useSupportLibrary = true

        // Room schema export
        ksp {
            arg("room.schemaLocation", "$projectDir/schemas")
        }
    }

    buildTypes {
        debug {
            isDebuggable = true
            isMinifyEnabled = false
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            
            buildConfigField("String", "API_BASE_URL", "\"https://api-dev.{{domain_name}}/\"")
            buildConfigField("boolean", "ENABLE_LOGGING", "true")
        }
        
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            buildConfigField("String", "API_BASE_URL", "\"https://api.{{domain_name}}/\"")
            buildConfigField("boolean", "ENABLE_LOGGING", "false")
            
            signingConfig = signingConfigs.getByName("debug") // Configure proper signing
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
        freeCompilerArgs += listOf(
            "-opt-in=kotlin.RequiresOptIn",
            "-opt-in=androidx.compose.material3.ExperimentalMaterial3Api",
            "-opt-in=androidx.compose.foundation.ExperimentalFoundationApi",
            "-opt-in=kotlinx.coroutines.ExperimentalCoroutinesApi"
        )
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = libs.versions.composeCompiler.get()
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
        }
    }
}

dependencies {
    // Core Android
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.androidx.lifecycle.runtime.compose)
    
    // Compose BOM
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.compose.material.icons.extended)
    
    // Navigation
    implementation(libs.androidx.navigation.compose)
    implementation(libs.androidx.hilt.navigation.compose)
    
    // Dependency Injection
    implementation(libs.hilt.android)
    kapt(libs.hilt.compiler)
    
    // Room Database
    implementation(libs.androidx.room.runtime)
    implementation(libs.androidx.room.ktx)
    ksp(libs.androidx.room.compiler)
    
    // Networking
    implementation(libs.retrofit)
    implementation(libs.retrofit.gson)
    implementation(libs.okhttp)
    implementation(libs.okhttp.logging)
    
    // Image Loading
    implementation(libs.coil.compose)
    
    // WorkManager
    implementation(libs.androidx.work.runtime.ktx)
    implementation(libs.androidx.hilt.work)
    kapt(libs.androidx.hilt.compiler)
    
    // Preferences
    implementation(libs.androidx.datastore.preferences)
    
    // Security
    implementation(libs.androidx.biometric)
    implementation(libs.androidx.security.crypto)
    
    // Splash Screen
    implementation(libs.androidx.core.splashscreen)
    
    // Permissions
    implementation(libs.accompanist.permissions)
    
    // Date/Time
    coreLibraryDesugaring(libs.desugar.jdk.libs)
    
    // Debug Tools
    debugImplementation(libs.androidx.compose.ui.tooling)
    debugImplementation(libs.androidx.compose.ui.test.manifest)
    debugImplementation(libs.leakcanary.android)
    
    // Testing
    testImplementation(libs.junit)
    testImplementation(libs.androidx.arch.core.testing)
    testImplementation(libs.kotlinx.coroutines.test)
    testImplementation(libs.mockk)
    testImplementation(libs.turbine)
    testImplementation(libs.robolectric)
    
    // Android Testing
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(platform(libs.androidx.compose.bom))
    androidTestImplementation(libs.androidx.compose.ui.test.junit4)
    androidTestImplementation(libs.hilt.android.testing)
    kaptAndroidTest(libs.hilt.compiler)
    androidTestImplementation(libs.androidx.room.testing)
    androidTestImplementation(libs.mockwebserver)
}
```

### Version Catalog (gradle/libs.versions.toml)
```toml
[versions]
# Core
kotlin = "2.0.0"
agp = "8.5.1"
coreKtx = "1.13.1"
lifecycleRuntimeKtx = "2.8.3"
activityCompose = "1.9.0"

# Compose
composeBom = "2024.06.00"
composeCompiler = "1.5.14"
navigation = "2.7.7"

# DI
hilt = "2.52"
hiltNavigation = "1.2.0"

# Database
room = "2.6.1"

# Network
retrofit = "2.11.0"
okhttp = "4.12.0"

# Image
coil = "2.7.0"

# Background
work = "2.9.0"

# Other
datastore = "1.1.1"
biometric = "1.2.0-alpha05"
securityCrypto = "1.1.0-alpha06"
splashscreen = "1.0.1"
accompanist = "0.34.0"
desugarJdkLibs = "2.0.4"

# Debug
leakcanary = "2.14"

# Testing
junit = "4.13.2"
junitVersion = "1.2.1"
espressoCore = "3.6.1"
archCore = "2.2.0"
coroutinesTest = "1.8.1"
mockk = "1.13.11"
turbine = "1.1.0"
robolectric = "4.12.2"
mockwebserver = "4.12.0"

# Quality
detekt = "1.23.6"
ktlint = "12.1.1"

[libraries]
# Core
androidx-core-ktx = { group = "androidx.core", name = "core-ktx", version.ref = "coreKtx" }
androidx-lifecycle-runtime-ktx = { group = "androidx.lifecycle", name = "lifecycle-runtime-ktx", version.ref = "lifecycleRuntimeKtx" }
androidx-activity-compose = { group = "androidx.activity", name = "activity-compose", version.ref = "activityCompose" }
androidx-lifecycle-viewmodel-compose = { group = "androidx.lifecycle", name = "lifecycle-viewmodel-compose", version.ref = "lifecycleRuntimeKtx" }
androidx-lifecycle-runtime-compose = { group = "androidx.lifecycle", name = "lifecycle-runtime-compose", version.ref = "lifecycleRuntimeKtx" }

# Compose
androidx-compose-bom = { group = "androidx.compose", name = "compose-bom", version.ref = "composeBom" }
androidx-compose-ui = { group = "androidx.compose.ui", name = "ui" }
androidx-compose-ui-tooling-preview = { group = "androidx.compose.ui", name = "ui-tooling-preview" }
androidx-compose-material3 = { group = "androidx.compose.material3", name = "material3" }
androidx-compose-material-icons-extended = { group = "androidx.compose.material", name = "material-icons-extended" }
androidx-compose-ui-tooling = { group = "androidx.compose.ui", name = "ui-tooling" }
androidx-compose-ui-test-manifest = { group = "androidx.compose.ui", name = "ui-test-manifest" }
androidx-compose-ui-test-junit4 = { group = "androidx.compose.ui", name = "ui-test-junit4" }

# Navigation
androidx-navigation-compose = { group = "androidx.navigation", name = "navigation-compose", version.ref = "navigation" }
androidx-hilt-navigation-compose = { group = "androidx.hilt", name = "hilt-navigation-compose", version.ref = "hiltNavigation" }

# Dependency Injection
hilt-android = { group = "com.google.dagger", name = "hilt-android", version.ref = "hilt" }
hilt-compiler = { group = "com.google.dagger", name = "hilt-compiler", version.ref = "hilt" }
hilt-android-testing = { group = "com.google.dagger", name = "hilt-android-testing", version.ref = "hilt" }

# Database
androidx-room-runtime = { group = "androidx.room", name = "room-runtime", version.ref = "room" }
androidx-room-ktx = { group = "androidx.room", name = "room-ktx", version.ref = "room" }
androidx-room-compiler = { group = "androidx.room", name = "room-compiler", version.ref = "room" }
androidx-room-testing = { group = "androidx.room", name = "room-testing", version.ref = "room" }

# Networking
retrofit = { group = "com.squareup.retrofit2", name = "retrofit", version.ref = "retrofit" }
retrofit-gson = { group = "com.squareup.retrofit2", name = "converter-gson", version.ref = "retrofit" }
okhttp = { group = "com.squareup.okhttp3", name = "okhttp", version.ref = "okhttp" }
okhttp-logging = { group = "com.squareup.okhttp3", name = "logging-interceptor", version.ref = "okhttp" }
mockwebserver = { group = "com.squareup.okhttp3", name = "mockwebserver", version.ref = "mockwebserver" }

# Image Loading
coil-compose = { group = "io.coil-kt", name = "coil-compose", version.ref = "coil" }

# Background Work
androidx-work-runtime-ktx = { group = "androidx.work", name = "work-runtime-ktx", version.ref = "work" }
androidx-hilt-work = { group = "androidx.hilt", name = "hilt-work", version.ref = "hiltNavigation" }

# Preferences
androidx-datastore-preferences = { group = "androidx.datastore", name = "datastore-preferences", version.ref = "datastore" }

# Security
androidx-biometric = { group = "androidx.biometric", name = "biometric", version.ref = "biometric" }
androidx-security-crypto = { group = "androidx.security", name = "security-crypto", version.ref = "securityCrypto" }

# Splash
androidx-core-splashscreen = { group = "androidx.core", name = "core-splashscreen", version.ref = "splashscreen" }

# Permissions
accompanist-permissions = { group = "com.google.accompanist", name = "accompanist-permissions", version.ref = "accompanist" }

# Date/Time
desugar-jdk-libs = { group = "com.android.tools", name = "desugar_jdk_libs", version.ref = "desugarJdkLibs" }

# Debug
leakcanary-android = { group = "com.squareup.leakcanary", name = "leakcanary-android", version.ref = "leakcanary" }

# Testing
junit = { group = "junit", name = "junit", version.ref = "junit" }
androidx-junit = { group = "androidx.test.ext", name = "junit", version.ref = "junitVersion" }
androidx-espresso-core = { group = "androidx.test.espresso", name = "espresso-core", version.ref = "espressoCore" }
androidx-arch-core-testing = { group = "androidx.arch.core", name = "core-testing", version.ref = "archCore" }
kotlinx-coroutines-test = { group = "org.jetbrains.kotlinx", name = "kotlinx-coroutines-test", version.ref = "coroutinesTest" }
mockk = { group = "io.mockk", name = "mockk", version.ref = "mockk" }
turbine = { group = "app.cash.turbine", name = "turbine", version.ref = "turbine" }
robolectric = { group = "org.robolectric", name = "robolectric", version.ref = "robolectric" }

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
jetbrains-kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
hilt = { id = "com.google.dagger.hilt.android", version.ref = "hilt" }
kotlin-parcelize = { id = "org.jetbrains.kotlin.plugin.parcelize", version.ref = "kotlin" }
androidx-navigation-safeargs = { id = "androidx.navigation.safeargs.kotlin", version.ref = "navigation" }
ksp = { id = "com.google.devtools.ksp", version = "2.0.0-1.0.22" }
detekt = { id = "io.gitlab.arturbosch.detekt", version.ref = "detekt" }
ktlint = { id = "org.jlleitschuh.gradle.ktlint", version.ref = "ktlint" }
```

### Development Commands
```bash
# Build debug version
./gradlew assembleDebug

# Build release version
./gradlew assembleRelease

# Run unit tests
./gradlew testDebugUnitTest

# Run instrumented tests
./gradlew connectedDebugAndroidTest

# Run all tests with coverage
./gradlew jacocoTestReport

# Run code quality checks
./gradlew detekt ktlintCheck lint

# Fix code formatting
./gradlew ktlintFormat

# Install debug APK
./gradlew installDebug

# Clean project
./gradlew clean

# Generate bundle for Play Store
./gradlew bundleRelease

# Run specific test class
./gradlew testDebugUnitTest --tests "*.LoginViewModelTest"

# Run UI tests on specific device
./gradlew connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.LoginScreenTest
```

## VALIDATION_SCRIPTS

```kotlin
// Project structure validation
object ProjectStructureValidator {
    
    private val requiredDirectories = listOf(
        "app/src/main/kotlin/${basePackage.replace('.', '/')}/data/local/database/entity",
        "app/src/main/kotlin/${basePackage.replace('.', '/')}/data/local/dao",
        "app/src/main/kotlin/${basePackage.replace('.', '/')}/data/remote/api",
        "app/src/main/kotlin/${basePackage.replace('.', '/')}/data/repository",
        "app/src/main/kotlin/${basePackage.replace('.', '/')}/domain/model",
        "app/src/main/kotlin/${basePackage.replace('.', '/')}/domain/usecase",
        "app/src/main/kotlin/${basePackage.replace('.', '/')}/presentation/screen",
        "app/src/main/kotlin/${basePackage.replace('.', '/')}/presentation/viewmodel",
        "app/src/main/kotlin/${basePackage.replace('.', '/')}/presentation/component",
        "app/src/main/kotlin/${basePackage.replace('.', '/')}/di",
        "app/src/test/kotlin/${basePackage.replace('.', '/')}",
        "app/src/androidTest/kotlin/${basePackage.replace('.', '/')}"
    )
    
    private val requiredFiles = listOf(
        "app/build.gradle.kts",
        "gradle/libs.versions.toml",
        "app/src/main/kotlin/${basePackage.replace('.', '/')}/MyApplication.kt",
        "app/src/main/kotlin/${basePackage.replace('.', '/')}/MainActivity.kt",
        "app/src/main/AndroidManifest.xml",
        "app/proguard-rules.pro"
    )
    
    fun validateProjectStructure(): Boolean {
        return requiredDirectories.all { File(it).exists() && File(it).isDirectory() } &&
               requiredFiles.all { File(it).exists() && File(it).isFile() }
    }
}

// Dependency validation
object DependencyValidator {
    
    private val requiredDependencies = listOf(
        "androidx.core:core-ktx",
        "androidx.lifecycle:lifecycle-runtime-ktx",
        "androidx.activity:activity-compose",
        "androidx.compose.ui:ui",
        "androidx.compose.material3:material3",
        "androidx.navigation:navigation-compose",
        "com.google.dagger:hilt-android",
        "androidx.room:room-runtime",
        "androidx.room:room-ktx",
        "com.squareup.retrofit2:retrofit",
        "com.squareup.okhttp3:okhttp",
        "io.coil-kt:coil-compose",
        "androidx.work:work-runtime-ktx"
    )
    
    fun validateDependencies(buildGradleContent: String): Boolean {
        return requiredDependencies.all { dependency ->
            buildGradleContent.contains(dependency.split(":")[1])
        }
    }
}

// Manifest validation
object ManifestValidator {
    
    private val requiredPermissions = listOf(
        "android.permission.INTERNET",
        "android.permission.ACCESS_NETWORK_STATE"
    )
    
    private val requiredComponents = listOf(
        "android.app.Application",
        "androidx.activity.ComponentActivity"
    )
    
    fun validateManifest(manifestContent: String): Boolean {
        return requiredPermissions.all { permission ->
            manifestContent.contains(permission)
        } && manifestContent.contains("android:theme") &&
           manifestContent.contains("android:allowBackup")
    }
}

// Build configuration validation
object BuildConfigValidator {
    
    fun validateBuildConfig(): Boolean {
        return validateMinSdk() &&
               validateTargetSdk() &&
               validateCompileSdk() &&
               validateKotlinVersion() &&
               validateComposeEnabled()
    }
    
    private fun validateMinSdk(): Boolean {
        // Check minSdk >= 24
        return true // Placeholder implementation
    }
    
    private fun validateTargetSdk(): Boolean {
        // Check targetSdk >= 34
        return true // Placeholder implementation  
    }
    
    private fun validateCompileSdk(): Boolean {
        // Check compileSdk >= 34
        return true // Placeholder implementation
    }
    
    private fun validateKotlinVersion(): Boolean {
        // Check Kotlin version >= 1.9.0
        return true // Placeholder implementation
    }
    
    private fun validateComposeEnabled(): Boolean {
        // Check buildFeatures.compose = true
        return true // Placeholder implementation
    }
}
```

## PROJECT_VARIABLES
- **PROJECT_NAME**: {{project_name}}
- **BASE_PACKAGE**: {{base_package}}
- **APPLICATION_NAME**: {{application_name}}
- **APPLICATION_ID**: {{application_id}}
- **DOMAIN_NAME**: {{domain_name}}
- **API_BASE_URL**: {{api_base_url}}
- **DATABASE_NAME**: {{database_name}}
- **COMPANY_NAME**: {{company_name}}
- **DEVELOPER_NAME**: {{developer_name}}
- **SUPPORT_EMAIL**: {{support_email}}
- **PRIVACY_POLICY_URL**: {{privacy_policy_url}}
- **TERMS_OF_SERVICE_URL**: {{terms_of_service_url}}

## CONDITIONAL_REQUIREMENTS

### IF authentication_type == "social"
```kotlin
// Google Sign-In configuration
dependencies {
    implementation("com.google.android.gms:play-services-auth:21.2.0")
    implementation("androidx.credentials:credentials:1.2.2")
    implementation("androidx.credentials:credentials-play-services-auth:1.2.2")
    implementation("com.google.android.libraries.identity.googleid:googleid:1.1.1")
}

// Facebook Login configuration  
dependencies {
    implementation("com.facebook.android:facebook-login:17.0.0")
}

// Social authentication repository
@Singleton
class SocialAuthRepository @Inject constructor(
    private val context: Context,
    private val credentialManager: CredentialManager
) {
    
    suspend fun signInWithGoogle(): Result<AuthResponse> {
        return try {
            val googleIdOption = GetGoogleIdOption.Builder()
                .setFilterByAuthorizedAccounts(false)
                .setServerClientId(BuildConfig.GOOGLE_CLIENT_ID)
                .build()
            
            val request = GetCredentialRequest.Builder()
                .addCredentialOption(googleIdOption)
                .build()
            
            val result = credentialManager.getCredential(context, request)
            val credential = result.credential
            
            if (credential is GoogleIdTokenCredential) {
                val idToken = credential.idToken
                // Send token to your backend
                authenticateWithBackend(idToken, "google")
            } else {
                Result.failure(Exception("Invalid credential type"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    private suspend fun authenticateWithBackend(
        token: String, 
        provider: String
    ): Result<AuthResponse> {
        // Implementation for backend authentication
        return Result.success(AuthResponse(accessToken = "", user = User()))
    }
}
```

### IF payment_integration == "stripe"
```kotlin
// Stripe payment configuration
dependencies {
    implementation("com.stripe:stripe-android:20.48.0")
}

// Payment configuration
class StripePaymentConfig {
    companion object {
        const val PUBLISHABLE_KEY = BuildConfig.STRIPE_PUBLISHABLE_KEY
        const val MERCHANT_ID = "{{merchant_id}}"
    }
}

// Payment repository
@Singleton
class PaymentRepository @Inject constructor(
    private val paymentApiService: PaymentApiService,
    private val stripe: Stripe
) {
    
    suspend fun processPayment(
        amount: Long,
        currency: String,
        paymentMethodId: String
    ): Result<PaymentResult> {
        return try {
            val paymentIntent = paymentApiService.createPaymentIntent(
                CreatePaymentIntentRequest(
                    amount = amount,
                    currency = currency,
                    paymentMethodId = paymentMethodId
                )
            )
            
            val confirmResult = stripe.confirmPayment(
                context = context,
                confirmPaymentIntentParams = ConfirmPaymentIntentParams
                    .createWithPaymentMethodId(
                        paymentMethodId = paymentMethodId,
                        clientSecret = paymentIntent.clientSecret
                    )
            )
            
            when (confirmResult) {
                is PaymentResult.Completed -> Result.success(confirmResult)
                is PaymentResult.Canceled -> Result.failure(Exception("Payment canceled"))
                is PaymentResult.Failed -> Result.failure(confirmResult.throwable)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

### IF push_notifications == "firebase"
```kotlin
// Firebase configuration
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.1.1"))
    implementation("com.google.firebase:firebase-messaging-ktx")
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-crashlytics-ktx")
}

// Firebase messaging service
@AndroidEntryPoint
class MyFirebaseMessagingService : FirebaseMessagingService() {
    
    @Inject
    lateinit var notificationManager: NotificationManager
    
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        
        remoteMessage.notification?.let { notification ->
            showNotification(
                title = notification.title ?: "",
                body = notification.body ?: "",
                data = remoteMessage.data
            )
        }
    }
    
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        // Send token to your backend
        sendTokenToBackend(token)
    }
    
    private fun showNotification(title: String, body: String, data: Map<String, String>) {
        notificationManager.showNotification(
            title = title,
            message = body,
            data = data
        )
    }
    
    private fun sendTokenToBackend(token: String) {
        // Implementation to send FCM token to backend
    }
}

// Notification manager
@Singleton
class NotificationManager @Inject constructor(
    @ApplicationContext private val context: Context
) {
    
    private val notificationManager = 
        context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
    
    init {
        createNotificationChannels()
    }
    
    fun showNotification(title: String, message: String, data: Map<String, String>) {
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(message)
            .setSmallIcon(R.drawable.ic_notification)
            .setAutoCancel(true)
            .build()
        
        notificationManager.notify(System.currentTimeMillis().toInt(), notification)
    }
    
    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "App Notifications",
                android.app.NotificationManager.IMPORTANCE_DEFAULT
            )
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    companion object {
        private const val CHANNEL_ID = "app_notifications"
    }
}
```

### IF analytics_tracking == "enabled"
```kotlin
// Analytics configuration
dependencies {
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.mixpanel.android:mixpanel-android:7.5.0")
}

// Analytics manager
@Singleton
class AnalyticsManager @Inject constructor(
    @ApplicationContext private val context: Context
) {
    
    private val firebaseAnalytics = FirebaseAnalytics.getInstance(context)
    private val mixpanel = MixpanelAPI.getInstance(context, BuildConfig.MIXPANEL_TOKEN, true)
    
    fun trackEvent(eventName: String, parameters: Map<String, Any> = emptyMap()) {
        // Firebase Analytics
        val bundle = Bundle().apply {
            parameters.forEach { (key, value) ->
                when (value) {
                    is String -> putString(key, value)
                    is Int -> putInt(key, value)
                    is Long -> putLong(key, value)
                    is Double -> putDouble(key, value)
                    is Boolean -> putBoolean(key, value)
                }
            }
        }
        firebaseAnalytics.logEvent(eventName, bundle)
        
        // Mixpanel
        val jsonObject = JSONObject().apply {
            parameters.forEach { (key, value) ->
                put(key, value)
            }
        }
        mixpanel.track(eventName, jsonObject)
    }
    
    fun setUserProperty(property: String, value: String) {
        firebaseAnalytics.setUserProperty(property, value)
        mixpanel.people.set(property, value)
    }
    
    fun identifyUser(userId: String) {
        firebaseAnalytics.setUserId(userId)
        mixpanel.identify(userId)
    }
}

// Analytics events
object AnalyticsEvents {
    const val USER_LOGIN = "user_login"
    const val USER_REGISTER = "user_register"
    const val PRODUCT_VIEW = "product_view"
    const val ADD_TO_CART = "add_to_cart"
    const val PURCHASE = "purchase"
    const val SEARCH = "search"
}
```

### IF offline_support == "enabled"
```kotlin
// Offline support configuration
@Singleton
class OfflineManager @Inject constructor(
    private val userDao: UserDao,
    private val productDao: ProductDao,
    private val orderDao: OrderDao,
    private val syncManager: SyncManager
) {
    
    fun enableOfflineMode() {
        // Cache critical data for offline access
        cacheEssentialData()
    }
    
    private suspend fun cacheEssentialData() {
        try {
            // Cache user profile
            val userProfile = userRepository.getUserProfile()
            userDao.insertUser(userProfile.toEntity())
            
            // Cache recent products
            val recentProducts = productRepository.getRecentProducts()
            productDao.insertProducts(recentProducts.map { it.toEntity() })
            
            // Cache cart items
            val cartItems = cartRepository.getCartItems()
            cartDao.insertCartItems(cartItems.map { it.toEntity() })
            
        } catch (e: Exception) {
            // Handle caching errors
        }
    }
    
    suspend fun syncWhenOnline() {
        if (networkManager.isOnline()) {
            syncManager.syncPendingChanges()
        }
    }
}

// Network state observer
@Singleton
class NetworkManager @Inject constructor(
    @ApplicationContext private val context: Context
) {
    
    private val _networkState = MutableStateFlow(NetworkState.UNKNOWN)
    val networkState: StateFlow<NetworkState> = _networkState.asStateFlow()
    
    private val networkCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            _networkState.value = NetworkState.AVAILABLE
        }
        
        override fun onLost(network: Network) {
            _networkState.value = NetworkState.LOST
        }
        
        override fun onUnavailable() {
            _networkState.value = NetworkState.UNAVAILABLE
        }
    }
    
    fun startMonitoring() {
        val connectivityManager = context.getSystemService(ConnectivityManager::class.java)
        val networkRequest = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()
        
        connectivityManager.registerNetworkCallback(networkRequest, networkCallback)
    }
    
    fun isOnline(): Boolean {
        val connectivityManager = context.getSystemService(ConnectivityManager::class.java)
        val network = connectivityManager.activeNetwork ?: return false
        val networkCapabilities = connectivityManager.getNetworkCapabilities(network) ?: return false
        
        return networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    }
}

enum class NetworkState {
    AVAILABLE, LOST, UNAVAILABLE, UNKNOWN
}
```

## INCLUDE_MODULES
- @include: android-security-best-practices.md
- @include: jetpack-compose-ui-components.md
- @include: room-database-setup.md
- @include: retrofit-networking-configuration.md
- @include: hilt-dependency-injection.md
- @include: android-testing-strategies.md
- @include: material-design-3-theming.md
- @include: android-performance-optimization.md
- @include: android-accessibility-implementation.md
- @include: android-localization-i18n.md

## VALIDATION_CHECKLIST
- [ ] All Kotlin compilation errors resolved without warnings
- [ ] Android application builds successfully for debug and release variants
- [ ] All Gradle dependencies properly configured with version catalogs
- [ ] Hilt dependency injection working correctly across all modules
- [ ] Room database migrations execute successfully without data loss
- [ ] Retrofit API calls working with proper error handling and authentication
- [ ] Jetpack Compose UI renders correctly on all target screen sizes
- [ ] Navigation between screens working with proper back stack management
- [ ] Material Design 3 theming implemented consistently across the app
- [ ] Authentication flow complete with token management and session handling
- [ ] Local data persistence working with Room and DataStore
- [ ] Image loading and caching working efficiently with Coil
- [ ] Background tasks executing properly with WorkManager
- [ ] Push notifications receiving and displaying correctly
- [ ] Offline functionality working with proper data synchronization
- [ ] Security measures implemented (certificate pinning, data encryption)
- [ ] Performance optimization achieving 60fps UI rendering
- [ ] Memory usage optimized without leaks or excessive allocation
- [ ] Unit tests covering all business logic with 90%+ coverage
- [ ] Integration tests passing for database and network operations
- [ ] UI tests covering critical user flows and edge cases
- [ ] Accessibility features working with TalkBack and other assistive technologies
- [ ] Internationalization support working for multiple languages
- [ ] ProGuard/R8 obfuscation working without breaking functionality
- [ ] App signing configured for Play Store release
- [ ] Crash reporting and analytics tracking working correctly
- [ ] App permissions properly declared and requested at runtime
- [ ] Network security configuration preventing cleartext traffic
- [ ] App size optimized under recommended limits (150MB)
- [ ] Battery optimization considerations implemented
- [ ] Android App Bundle builds successfully for Play Store deployment

## PERFORMANCE_REQUIREMENTS
- **App Startup Time**: Cold start < 2 seconds, warm start < 1 second
- **UI Rendering**: Maintain 60fps during scrolling and animations
- **Memory Usage**: < 200MB RAM usage under normal operation
- **Network Efficiency**: API response caching and request batching
- **Battery Usage**: Minimal background activity and efficient wake locks
- **Storage Usage**: < 100MB for app installation, efficient cache management
- **Image Loading**: < 1 second for high-resolution images with progressive loading
- **Database Operations**: < 100ms for simple queries, < 500ms for complex joins
- **Search Performance**: < 500ms for local search, < 2 seconds for remote search
- **Offline Performance**: Full functionality available without network connection

## MONITORING_AND_OBSERVABILITY

### Crash Reporting
```kotlin
// Firebase Crashlytics configuration
class CrashReportingManager {
    
    fun logCrash(exception: Throwable, message: String? = null) {
        FirebaseCrashlytics.getInstance().apply {
            message?.let { log(it) }
            recordException(exception)
        }
    }
    
    fun setUserId(userId: String) {
        FirebaseCrashlytics.getInstance().setUserId(userId)
    }
    
    fun addBreadcrumb(message: String) {
        FirebaseCrashlytics.getInstance().log(message)
    }
}
```

### Performance Monitoring
```kotlin
// Performance tracking
class PerformanceMonitor {
    
    fun trackScreenLoad(screenName: String) {
        val trace = FirebasePerformance.getInstance().newTrace("screen_load_$screenName")
        trace.start()
        // Stop trace when screen is fully loaded
    }
    
    fun trackApiCall(endpoint: String, method: String) {
        val httpMetric = FirebasePerformance.getInstance()
            .newHttpMetric(endpoint, method)
        httpMetric.start()
        // Stop metric when API call completes
    }
}
```

### User Behavior Analytics
```kotlin
// User behavior tracking
class UserBehaviorTracker {
    
    fun trackUserJourney(step: String, metadata: Map<String, String> = emptyMap()) {
        analyticsManager.trackEvent("user_journey_$step", metadata)
    }
    
    fun trackFeatureUsage(feature: String, duration: Long) {
        analyticsManager.trackEvent("feature_usage", mapOf(
            "feature" => feature,
            "duration_ms" => duration
        ))
    }
}
```

## BUSINESS_LOGIC_EXAMPLES

### E-commerce Domain Models
```kotlin
// User domain model
@Parcelize
data class User(
    val id: Long,
    val email: String,
    val firstName: String,
    val lastName: String,
    val phoneNumber: String?,
    val profileImageUrl: String?,
    val isEmailVerified: Boolean,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
) : Parcelable {
    val fullName: String get() = "$firstName $lastName"
    val initials: String get() = "${firstName.firstOrNull()}${lastName.firstOrNull()}"
}

// Product domain model
@Parcelize
data class Product(
    val id: Long,
    val name: String,
    val description: String,
    val price: BigDecimal,
    val currency: String,
    val imageUrls: List<String>,
    val category: Category,
    val rating: Float,
    val reviewCount: Int,
    val isInStock: Boolean,
    val stockQuantity: Int,
    val tags: List<String>,
    val createdAt: LocalDateTime
) : Parcelable {
    val formattedPrice: String get() = "$currency ${price.toPlainString()}"
    val isAvailable: Boolean get() = isInStock && stockQuantity > 0
}

// Order domain model
@Parcelize
data class Order(
    val id: Long,
    val userId: Long,
    val items: List<OrderItem>,
    val status: OrderStatus,
    val subtotal: BigDecimal,
    val tax: BigDecimal,
    val shipping: BigDecimal,
    val total: BigDecimal,
    val shippingAddress: Address,
    val paymentMethod: PaymentMethod,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
) : Parcelable

enum class OrderStatus {
    PENDING, CONFIRMED, PROCESSING, SHIPPED, DELIVERED, CANCELLED
}

// Shopping Cart
@Parcelize
data class Cart(
    val items: List<CartItem>,
    val subtotal: BigDecimal,
    val tax: BigDecimal,
    val total: BigDecimal
) : Parcelable {
    val itemCount: Int get() = items.sumOf { it.quantity }
    val isEmpty: Boolean get() = items.isEmpty()
}

@Parcelize
data class CartItem(
    val productId: Long,
    val product: Product,
    val quantity: Int,
    val price: BigDecimal
) : Parcelable {
    val totalPrice: BigDecimal get() = price.multiply(BigDecimal(quantity))
}
```

### Repository Implementation Examples
```kotlin
// User repository implementation
@Singleton
class UserRepositoryImpl @Inject constructor(
    private val userApiService: UserApiService,
    private val userDao: UserDao,
    private val userPreferences: UserPreferences
) : UserRepository {
    
    override suspend fun getUserProfile(): Result<User> {
        return try {
            val response = userApiService.getUserProfile()
            val user = response.data.toDomainModel()
            
            // Cache user data locally
            userDao.insertUser(user.toEntity())
            
            Result.success(user)
        } catch (e: Exception) {
            // Fallback to cached data
            val cachedUser = userDao.getUser()?.toDomainModel()
            if (cachedUser != null) {
                Result.success(cachedUser)
            } else {
                Result.failure(e)
            }
        }
    }
    
    override suspend fun updateUserProfile(user: User): Result<User> {
        return try {
            val request = user.toUpdateRequest()
            val response = userApiService.updateUserProfile(request)
            val updatedUser = response.data.toDomainModel()
            
            // Update cached data
            userDao.updateUser(updatedUser.toEntity())
            
            Result.success(updatedUser)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    override fun observeUserProfile(): Flow<User?> {
        return userDao.observeUser().map { it?.toDomainModel() }
    }
}

// Product repository implementation
@Singleton
class ProductRepositoryImpl @Inject constructor(
    private val productApiService: ProductApiService,
    private val productDao: ProductDao,
    private val cacheManager: CacheManager
) : ProductRepository {
    
    override suspend fun getProducts(
        categoryId: Long?,
        searchQuery: String?,
        page: Int,
        pageSize: Int
    ): Result<PaginatedList<Product>> {
        return try {
            val response = productApiService.getProducts(
                categoryId = categoryId,
                search = searchQuery,
                page = page,
                limit = pageSize
            )
            
            val products = response.data.map { it.toDomainModel() }
            
            // Cache products for offline access
            if (page == 1) {
                productDao.clearAndInsertProducts(products.map { it.toEntity() })
            } else {
                productDao.insertProducts(products.map { it.toEntity() })
            }
            
            Result.success(
                PaginatedList(
                    items = products,
                    hasNextPage = response.hasNextPage,
                    totalCount = response.totalCount
                )
            )
        } catch (e: Exception) {
            // Fallback to cached data for first page
            if (page == 1) {
                val cachedProducts = productDao.getProducts().map { it.toDomainModel() }
                Result.success(
                    PaginatedList(
                        items = cachedProducts,
                        hasNextPage = false,
                        totalCount = cachedProducts.size
                    )
                )
            } else {
                Result.failure(e)
            }
        }
    }
    
    override suspend fun getProductDetails(productId: Long): Result<Product> {
        return try {
            val response = productApiService.getProductDetails(productId)
            val product = response.data.toDomainModel()
            
            // Update cache
            productDao.insertProduct(product.toEntity())
            
            Result.success(product)
        } catch (e: Exception) {
            // Try to get from cache
            val cachedProduct = productDao.getProduct(productId)?.toDomainModel()
            if (cachedProduct != null) {
                Result.success(cachedProduct)
            } else {
                Result.failure(e)
            }
        }
    }
}
```

### ViewModel Implementation Examples
```kotlin
// Login ViewModel
@HiltViewModel
class LoginViewModel @Inject constructor(
    private val loginUseCase: LoginUseCase,
    private val analyticsManager: AnalyticsManager
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()
    
    fun login(email: String, password: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            
            val result = loginUseCase(LoginUseCase.Params(email, password))
            
            result.fold(
                onSuccess = { authResponse ->
                    analyticsManager.trackEvent(AnalyticsEvents.USER_LOGIN)
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            isLoginSuccessful = true
                        )
                    }
                },
                onFailure = { exception ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            error = exception.message ?: "Login failed"
                        )
                    }
                }
            )
        }
    }
    
    fun clearError() {
        _uiState.update { it.copy(error = null) }
    }
}

data class LoginUiState(
    val isLoading: Boolean = false,
    val isLoginSuccessful: Boolean = false,
    val error: String? = null
)

// Product List ViewModel
@HiltViewModel
class ProductListViewModel @Inject constructor(
    private val getProductsUseCase: GetProductsUseCase,
    private val addToCartUseCase: AddToCartUseCase,
    private val analyticsManager: AnalyticsManager
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(ProductListUiState())
    val uiState: StateFlow<ProductListUiState> = _uiState.asStateFlow()
    
    private var currentPage = 1
    private var canLoadMore = true
    
    init {
        loadProducts()
    }
    
    fun loadProducts(refresh: Boolean = false) {
        viewModelScope.launch {
            if (refresh) {
                currentPage = 1
                canLoadMore = true
                _uiState.update { it.copy(isRefreshing = true) }
            } else if (!canLoadMore || _uiState.value.isLoading) {
                return@launch
            }
            
            _uiState.update { it.copy(isLoading = true) }
            
            val result = getProductsUseCase(
                GetProductsUseCase.Params(
                    categoryId = _uiState.value.selectedCategoryId,
                    searchQuery = _uiState.value.searchQuery,
                    page = currentPage
                )
            )
            
            result.fold(
                onSuccess = { paginatedProducts ->
                    val updatedProducts = if (refresh || currentPage == 1) {
                        paginatedProducts.items
                    } else {
                        _uiState.value.products + paginatedProducts.items
                    }
                    
                    _uiState.update {
                        it.copy(
                            products = updatedProducts,
                            isLoading = false,
                            isRefreshing = false,
                            error = null
                        )
                    }
                    
                    currentPage++
                    canLoadMore = paginatedProducts.hasNextPage
                },
                onFailure = { exception ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            isRefreshing = false,
                            error = exception.message
                        )
                    }
                }
            )
        }
    }
    
    fun addToCart(product: Product) {
        viewModelScope.launch {
            val result = addToCartUseCase(
                AddToCartUseCase.Params(product.id, quantity = 1)
            )
            
            result.fold(
                onSuccess = {
                    analyticsManager.trackEvent(
                        AnalyticsEvents.ADD_TO_CART,
                        mapOf(
                            "product_id" to product.id.toString(),
                            "product_name" to product.name
                        )
                    )
                    // Show success message
                },
                onFailure = { exception ->
                    // Show error message
                }
            )
        }
    }
    
    fun search(query: String) {
        _uiState.update { it.copy(searchQuery = query) }
        loadProducts(refresh = true)
    }
    
    fun selectCategory(categoryId: Long?) {
        _uiState.update { it.copy(selectedCategoryId = categoryId) }
        loadProducts(refresh = true)
    }
}

data class ProductListUiState(
    val products: List<Product> = emptyList(),
    val isLoading: Boolean = false,
    val isRefreshing: Boolean = false,
    val error: String? = null,
    val searchQuery: String = "",
    val selectedCategoryId: Long? = null
)
```

This completes the comprehensive Kotlin Android Native application template with:

1. **Complete project structure** with modern Android architecture
2. **Production-ready build configuration** with Gradle Kotlin DSL and version catalogs
3. **Comprehensive dependency setup** with latest Jetpack libraries
4. **Advanced security implementation** with biometric auth and encryption
5. **Performance optimization** with proper memory management and 60fps UI
6. **Testing strategy** covering unit, integration, and UI tests
7. **Conditional features** for social auth, payments, push notifications, and analytics
8. **Real-world business logic examples** with e-commerce domain models
9. **Complete validation checklist** ensuring production readiness
10. **Monitoring and observability** with crash reporting and performance tracking

The template follows modern Android development best practices and provides a solid foundation for building production-grade native Android applications with Kotlin and Jetpack Compose.