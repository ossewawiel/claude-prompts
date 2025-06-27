# Spring Boot JWT Security Best Practices - Claude Code Integration

## Document Information
- **Purpose**: Comprehensive JWT security best practices for Spring Boot with Java and Kotlin
- **Last Updated**: June 26, 2025
- **Document Version**: 2.0.0
- **Target Frameworks**: Spring Boot 3.x, Spring Security 6.x, Java 17+, Kotlin 2.1+
- **Integration**: Designed for Claude Code analysis and project validation

## Table of Contents
1. [Library Dependencies](#library-dependencies)
2. [JWT Configuration](#jwt-configuration)
3. [Security Configuration](#security-configuration)
4. [JWT Service Implementation](#jwt-service-implementation)
5. [Authentication Filter](#authentication-filter)
6. [Controller Implementation](#controller-implementation)
7. [Exception Handling](#exception-handling)
8. [Testing Standards](#testing-standards)
9. [Security Hardening](#security-hardening)
10. [Validation Checklist](#validation-checklist)

---

## Library Dependencies

### Essential Dependencies (Maven)
```xml
<dependencies>
    <!-- Spring Boot Security Starter -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    
    <!-- JWT Library -->
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-api</artifactId>
        <version>0.12.5</version>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-impl</artifactId>
        <version>0.12.5</version>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-jackson</artifactId>
        <version>0.12.5</version>
        <scope>runtime</scope>
    </dependency>
    
    <!-- Spring Boot Validation -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
</dependencies>
```

### Essential Dependencies (Gradle Kotlin)
```kotlin
dependencies {
    // Spring Boot Security
    implementation("org.springframework.boot:spring-boot-starter-security")
    
    // JWT Library (latest stable)
    implementation("io.jsonwebtoken:jjwt-api:0.12.5")
    runtimeOnly("io.jsonwebtoken:jjwt-impl:0.12.5")
    runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.12.5")
    
    // Validation
    implementation("org.springframework.boot:spring-boot-starter-validation")
    
    // Kotlin specific
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("org.jetbrains.kotlin:kotlin-reflect")
}
```

---

## JWT Configuration

### Application Properties
```yaml
# application.yml
app:
  jwt:
    secret: ${JWT_SECRET:mySecretKey} # Use environment variable in production
    expiration-ms: 86400000 # 24 hours
    refresh-expiration-ms: 604800000 # 7 days
    issuer: "my-app"
    audience: "my-app-users"

spring:
  security:
    require-ssl: true # Production only
  application:
    name: secure-jwt-app

logging:
  level:
    org.springframework.security: DEBUG # Development only
    com.myapp.security: DEBUG # Development only
```

### Configuration Properties Class

#### Java Implementation
```java
@ConfigurationProperties(prefix = "app.jwt")
@Validated
public record JwtProperties(
    @NotBlank String secret,
    @Positive long expirationMs,
    @Positive long refreshExpirationMs,
    @NotBlank String issuer,
    @NotBlank String audience
) {
    public Duration getExpirationDuration() {
        return Duration.ofMillis(expirationMs);
    }
    
    public Duration getRefreshExpirationDuration() {
        return Duration.ofMillis(refreshExpirationMs);
    }
}
```

#### Kotlin Implementation
```kotlin
@ConfigurationProperties(prefix = "app.jwt")
@Validated
data class JwtProperties(
    @field:NotBlank val secret: String,
    @field:Positive val expirationMs: Long,
    @field:Positive val refreshExpirationMs: Long,
    @field:NotBlank val issuer: String,
    @field:NotBlank val audience: String
) {
    val expirationDuration: Duration
        get() = Duration.ofMillis(expirationMs)
    
    val refreshExpirationDuration: Duration
        get() = Duration.ofMillis(refreshExpirationMs)
}
```

---

## Security Configuration

### Java Security Configuration
```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true, jsr250Enabled = true)
public class SecurityConfig {

    private final JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    private final JwtRequestFilter jwtRequestFilter;
    private final CustomAccessDeniedHandler accessDeniedHandler;

    public SecurityConfig(
        JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint,
        JwtRequestFilter jwtRequestFilter,
        CustomAccessDeniedHandler accessDeniedHandler
    ) {
        this.jwtAuthenticationEntryPoint = jwtAuthenticationEntryPoint;
        this.jwtRequestFilter = jwtRequestFilter;
        this.accessDeniedHandler = accessDeniedHandler;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12); // Strength 12 for security
    }

    @Bean
    public AuthenticationManager authenticationManager(
        AuthenticationConfiguration config
    ) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // Disabled for stateless JWT
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .authorizeHttpRequests(authz -> authz
                // Public endpoints
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/actuator/health").permitAll()
                
                // Admin endpoints
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                
                // User endpoints
                .requestMatchers(HttpMethod.GET, "/api/users/me").hasAnyRole("USER", "ADMIN")
                .requestMatchers(HttpMethod.PUT, "/api/users/me").hasAnyRole("USER", "ADMIN")
                
                // All other requests require authentication
                .anyRequest().authenticated()
            )
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint(jwtAuthenticationEntryPoint)
                .accessDeniedHandler(accessDeniedHandler)
            )
            .headers(headers -> headers
                .frameOptions().deny()
                .contentTypeOptions().and()
                .httpStrictTransportSecurity(hstsConfig -> hstsConfig
                    .maxAgeInSeconds(31536000)
                    .includeSubdomains(true)
                )
            );

        // Add JWT filter before UsernamePasswordAuthenticationFilter
        http.addFilterBefore(jwtRequestFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    @ConditionalOnProperty(name = "spring.profiles.active", havingValue = "dev")
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(List.of("*"));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", configuration);
        return source;
    }
}
```

### Kotlin Security Configuration
```kotlin
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true, jsr250Enabled = true)
class SecurityConfig(
    private val jwtAuthenticationEntryPoint: JwtAuthenticationEntryPoint,
    private val jwtRequestFilter: JwtRequestFilter,
    private val accessDeniedHandler: CustomAccessDeniedHandler
) {

    @Bean
    fun passwordEncoder(): PasswordEncoder = BCryptPasswordEncoder(12)

    @Bean
    fun authenticationManager(config: AuthenticationConfiguration): AuthenticationManager =
        config.authenticationManager

    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        http {
            csrf { disable() }
            sessionManagement { sessionCreationPolicy = SessionCreationPolicy.STATELESS }
            
            authorizeHttpRequests {
                // Public endpoints
                authorize("/api/auth/**", permitAll)
                authorize("/api/public/**", permitAll)
                authorize("/actuator/health", permitAll)
                
                // Admin endpoints
                authorize("/api/admin/**", hasRole("ADMIN"))
                
                // User endpoints
                authorize(HttpMethod.GET, "/api/users/me", hasAnyRole("USER", "ADMIN"))
                authorize(HttpMethod.PUT, "/api/users/me", hasAnyRole("USER", "ADMIN"))
                
                // All other requests require authentication
                authorize(anyRequest, authenticated)
            }
            
            exceptionHandling {
                authenticationEntryPoint = jwtAuthenticationEntryPoint
                accessDeniedHandler = this@SecurityConfig.accessDeniedHandler
            }
            
            headers {
                frameOptions { deny() }
                contentTypeOptions { }
                httpStrictTransportSecurity {
                    maxAgeInSeconds = 31536000
                    includeSubdomains = true
                }
            }
        }

        http.addFilterBefore(jwtRequestFilter, UsernamePasswordAuthenticationFilter::class.java)
        return http.build()
    }
}
```

---

## JWT Service Implementation

### Java JWT Service
```java
@Service
@Validated
public class JwtService {

    private static final Logger logger = LoggerFactory.getLogger(JwtService.class);
    
    private final JwtProperties jwtProperties;
    private final Key signingKey;

    public JwtService(JwtProperties jwtProperties) {
        this.jwtProperties = jwtProperties;
        this.signingKey = Keys.hmacShaKeyFor(jwtProperties.secret().getBytes(StandardCharsets.UTF_8));
    }

    public String generateAccessToken(@NotNull UserDetails userDetails) {
        return generateAccessToken(userDetails.getUsername(), getAuthorities(userDetails));
    }

    public String generateAccessToken(@NotBlank String username, Collection<String> authorities) {
        Instant now = Instant.now();
        
        return Jwts.builder()
            .subject(username)
            .claim("authorities", authorities)
            .claim("type", "access")
            .issuer(jwtProperties.issuer())
            .audience().add(jwtProperties.audience()).and()
            .issuedAt(Date.from(now))
            .expiration(Date.from(now.plus(jwtProperties.getExpirationDuration())))
            .signWith(signingKey, SignatureAlgorithm.HS512)
            .compact();
    }

    public String generateRefreshToken(@NotBlank String username) {
        Instant now = Instant.now();
        
        return Jwts.builder()
            .subject(username)
            .claim("type", "refresh")
            .issuer(jwtProperties.issuer())
            .audience().add(jwtProperties.audience()).and()
            .issuedAt(Date.from(now))
            .expiration(Date.from(now.plus(jwtProperties.getRefreshExpirationDuration())))
            .signWith(signingKey, SignatureAlgorithm.HS512)
            .compact();
    }

    public boolean validateToken(@NotBlank String token) {
        try {
            Jwts.parser()
                .verifyWith((SecretKey) signingKey)
                .requireIssuer(jwtProperties.issuer())
                .requireAudience(jwtProperties.audience())
                .build()
                .parseSignedClaims(token);
            return true;
        } catch (SecurityException e) {
            logger.error("Invalid JWT signature: {}", e.getMessage());
        } catch (MalformedJwtException e) {
            logger.error("Invalid JWT token: {}", e.getMessage());
        } catch (ExpiredJwtException e) {
            logger.error("JWT token is expired: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            logger.error("JWT token is unsupported: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            logger.error("JWT claims string is empty: {}", e.getMessage());
        }
        return false;
    }

    public String getUsernameFromToken(@NotBlank String token) {
        return getClaims(token).getSubject();
    }

    @SuppressWarnings("unchecked")
    public Collection<String> getAuthoritiesFromToken(@NotBlank String token) {
        Claims claims = getClaims(token);
        return (Collection<String>) claims.get("authorities", Collection.class);
    }

    public boolean isRefreshToken(@NotBlank String token) {
        return "refresh".equals(getClaims(token).get("type"));
    }

    private Claims getClaims(String token) {
        return Jwts.parser()
            .verifyWith((SecretKey) signingKey)
            .build()
            .parseSignedClaims(token)
            .getPayload();
    }

    private Collection<String> getAuthorities(UserDetails userDetails) {
        return userDetails.getAuthorities().stream()
            .map(GrantedAuthority::getAuthority)
            .collect(Collectors.toSet());
    }
}
```

### Kotlin JWT Service
```kotlin
@Service
@Validated
class JwtService(private val jwtProperties: JwtProperties) {

    companion object {
        private val logger = LoggerFactory.getLogger(JwtService::class.java)
    }

    private val signingKey: Key = Keys.hmacShaKeyFor(jwtProperties.secret.toByteArray(StandardCharsets.UTF_8))

    fun generateAccessToken(userDetails: UserDetails): String =
        generateAccessToken(userDetails.username, userDetails.getAuthorities())

    fun generateAccessToken(username: String, authorities: Collection<String>): String {
        val now = Instant.now()
        
        return Jwts.builder()
            .subject(username)
            .claim("authorities", authorities)
            .claim("type", "access")
            .issuer(jwtProperties.issuer)
            .audience().add(jwtProperties.audience).and()
            .issuedAt(Date.from(now))
            .expiration(Date.from(now.plus(jwtProperties.expirationDuration)))
            .signWith(signingKey, SignatureAlgorithm.HS512)
            .compact()
    }

    fun generateRefreshToken(username: String): String {
        val now = Instant.now()
        
        return Jwts.builder()
            .subject(username)
            .claim("type", "refresh")
            .issuer(jwtProperties.issuer)
            .audience().add(jwtProperties.audience).and()
            .issuedAt(Date.from(now))
            .expiration(Date.from(now.plus(jwtProperties.refreshExpirationDuration)))
            .signWith(signingKey, SignatureAlgorithm.HS512)
            .compact()
    }

    fun validateToken(token: String): Boolean {
        return try {
            Jwts.parser()
                .verifyWith(signingKey as SecretKey)
                .requireIssuer(jwtProperties.issuer)
                .requireAudience(jwtProperties.audience)
                .build()
                .parseSignedClaims(token)
            true
        } catch (e: SecurityException) {
            logger.error("Invalid JWT signature: {}", e.message)
            false
        } catch (e: MalformedJwtException) {
            logger.error("Invalid JWT token: {}", e.message)
            false
        } catch (e: ExpiredJwtException) {
            logger.error("JWT token is expired: {}", e.message)
            false
        } catch (e: UnsupportedJwtException) {
            logger.error("JWT token is unsupported: {}", e.message)
            false
        } catch (e: IllegalArgumentException) {
            logger.error("JWT claims string is empty: {}", e.message)
            false
        }
    }

    fun getUsernameFromToken(token: String): String = getClaims(token).subject

    @Suppress("UNCHECKED_CAST")
    fun getAuthoritiesFromToken(token: String): Collection<String> =
        getClaims(token)["authorities"] as Collection<String>

    fun isRefreshToken(token: String): Boolean = "refresh" == getClaims(token)["type"]

    private fun getClaims(token: String): Claims =
        Jwts.parser()
            .verifyWith(signingKey as SecretKey)
            .build()
            .parseSignedClaims(token)
            .payload

    private fun UserDetails.getAuthorities(): Collection<String> =
        authorities.map { it.authority }.toSet()
}
```

---

## Authentication Filter

### Java JWT Request Filter
```java
@Component
public class JwtRequestFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(JwtRequestFilter.class);
    
    private final UserDetailsService userDetailsService;
    private final JwtService jwtService;

    public JwtRequestFilter(UserDetailsService userDetailsService, JwtService jwtService) {
        this.userDetailsService = userDetailsService;
        this.jwtService = jwtService;
    }

    @Override
    protected void doFilterInternal(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain
    ) throws ServletException, IOException {
        
        try {
            String jwt = parseJwtFromRequest(request);
            
            if (jwt != null && jwtService.validateToken(jwt) && !jwtService.isRefreshToken(jwt)) {
                String username = jwtService.getUsernameFromToken(jwt);
                
                if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                    UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                    
                    UsernamePasswordAuthenticationToken authentication = 
                        new UsernamePasswordAuthenticationToken(
                            userDetails, null, userDetails.getAuthorities()
                        );
                    authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                    logger.debug("Set authentication for user: {}", username);
                }
            }
        } catch (Exception e) {
            logger.error("Cannot set user authentication: {}", e.getMessage());
            SecurityContextHolder.clearContext();
        }

        filterChain.doFilter(request, response);
    }

    private String parseJwtFromRequest(HttpServletRequest request) {
        String headerAuth = request.getHeader("Authorization");

        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            return headerAuth.substring(7);
        }

        return null;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return path.startsWith("/api/auth/") || 
               path.startsWith("/api/public/") || 
               path.equals("/actuator/health");
    }
}
```

### Kotlin JWT Request Filter
```kotlin
@Component
class JwtRequestFilter(
    private val userDetailsService: UserDetailsService,
    private val jwtService: JwtService
) : OncePerRequestFilter() {

    companion object {
        private val logger = LoggerFactory.getLogger(JwtRequestFilter::class.java)
    }

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        try {
            val jwt = parseJwtFromRequest(request)
            
            if (jwt != null && jwtService.validateToken(jwt) && !jwtService.isRefreshToken(jwt)) {
                val username = jwtService.getUsernameFromToken(jwt)
                
                if (username.isNotBlank() && SecurityContextHolder.getContext().authentication == null) {
                    val userDetails = userDetailsService.loadUserByUsername(username)
                    
                    val authentication = UsernamePasswordAuthenticationToken(
                        userDetails, null, userDetails.authorities
                    ).apply {
                        details = WebAuthenticationDetailsSource().buildDetails(request)
                    }
                    
                    SecurityContextHolder.getContext().authentication = authentication
                    logger.debug("Set authentication for user: {}", username)
                }
            }
        } catch (e: Exception) {
            logger.error("Cannot set user authentication: {}", e.message)
            SecurityContextHolder.clearContext()
        }

        filterChain.doFilter(request, response)
    }

    private fun parseJwtFromRequest(request: HttpServletRequest): String? {
        val headerAuth = request.getHeader("Authorization")
        return if (headerAuth?.startsWith("Bearer ") == true) {
            headerAuth.substring(7)
        } else null
    }

    override fun shouldNotFilter(request: HttpServletRequest): Boolean {
        val path = request.requestURI
        return path.startsWith("/api/auth/") || 
               path.startsWith("/api/public/") || 
               path == "/actuator/health"
    }
}
```

---

## Controller Implementation

### Java Authentication Controller
```java
@RestController
@RequestMapping("/api/auth")
@Validated
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);
    
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final UserService userService;
    private final RefreshTokenService refreshTokenService;

    public AuthController(
        AuthenticationManager authenticationManager,
        JwtService jwtService,
        UserService userService,
        RefreshTokenService refreshTokenService
    ) {
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
        this.userService = userService;
        this.refreshTokenService = refreshTokenService;
    }

    @PostMapping("/login")
    public ResponseEntity<JwtResponse> login(@Valid @RequestBody LoginRequest request) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.username(), request.password())
            );

            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            String accessToken = jwtService.generateAccessToken(userDetails);
            String refreshToken = jwtService.generateRefreshToken(userDetails.getUsername());
            
            // Store refresh token in database
            refreshTokenService.saveRefreshToken(userDetails.getUsername(), refreshToken);

            JwtResponse response = new JwtResponse(
                accessToken,
                refreshToken,
                "Bearer",
                userDetails.getUsername(),
                userDetails.getAuthorities().stream()
                    .map(GrantedAuthority::getAuthority)
                    .collect(Collectors.toSet())
            );

            logger.info("User {} logged in successfully", request.username());
            return ResponseEntity.ok(response);

        } catch (BadCredentialsException e) {
            logger.warn("Login attempt failed for user: {}", request.username());
            throw new AuthenticationException("Invalid credentials");
        }
    }

    @PostMapping("/refresh")
    public ResponseEntity<JwtResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        String refreshToken = request.refreshToken();
        
        if (!jwtService.validateToken(refreshToken) || !jwtService.isRefreshToken(refreshToken)) {
            throw new InvalidTokenException("Invalid refresh token");
        }

        String username = jwtService.getUsernameFromToken(refreshToken);
        
        if (!refreshTokenService.isValidRefreshToken(username, refreshToken)) {
            throw new InvalidTokenException("Refresh token not found or expired");
        }

        UserDetails userDetails = userService.loadUserByUsername(username);
        String newAccessToken = jwtService.generateAccessToken(userDetails);
        String newRefreshToken = jwtService.generateRefreshToken(username);
        
        // Update refresh token in database
        refreshTokenService.updateRefreshToken(username, refreshToken, newRefreshToken);

        JwtResponse response = new JwtResponse(
            newAccessToken,
            newRefreshToken,
            "Bearer",
            username,
            userDetails.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toSet())
        );

        return ResponseEntity.ok(response);
    }

    @PostMapping("/logout")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, String>> logout(
        @RequestHeader("Authorization") String authHeader,
        Authentication authentication
    ) {
        String token = authHeader.substring(7);
        String username = authentication.getName();
        
        // Invalidate refresh tokens
        refreshTokenService.revokeAllRefreshTokens(username);
        
        // Add access token to blacklist (if implementing token blacklisting)
        // tokenBlacklistService.blacklistToken(token);
        
        logger.info("User {} logged out successfully", username);
        return ResponseEntity.ok(Map.of("message", "Logout successful"));
    }
}
```

### Kotlin Authentication Controller
```kotlin
@RestController
@RequestMapping("/api/auth")
@Validated
class AuthController(
    private val authenticationManager: AuthenticationManager,
    private val jwtService: JwtService,
    private val userService: UserService,
    private val refreshTokenService: RefreshTokenService
) {
    companion object {
        private val logger = LoggerFactory.getLogger(AuthController::class.java)
    }

    @PostMapping("/login")
    fun login(@Valid @RequestBody request: LoginRequest): ResponseEntity<JwtResponse> {
        return try {
            val authentication = authenticationManager.authenticate(
                UsernamePasswordAuthenticationToken(request.username, request.password)
            )

            val userDetails = authentication.principal as UserDetails
            val accessToken = jwtService.generateAccessToken(userDetails)
            val refreshToken = jwtService.generateRefreshToken(userDetails.username)
            
            // Store refresh token in database
            refreshTokenService.saveRefreshToken(userDetails.username, refreshToken)

            val response = JwtResponse(
                accessToken = accessToken,
                refreshToken = refreshToken,
                tokenType = "Bearer",
                username = userDetails.username,
                authorities = userDetails.authorities.map { it.authority }.toSet()
            )

            logger.info("User {} logged in successfully", request.username)
            ResponseEntity.ok(response)

        } catch (e: BadCredentialsException) {
            logger.warn("Login attempt failed for user: {}", request.username)
            throw AuthenticationException("Invalid credentials")
        }
    }

    @PostMapping("/refresh")
    fun refreshToken(@Valid @RequestBody request: RefreshTokenRequest): ResponseEntity<JwtResponse> {
        val refreshToken = request.refreshToken
        
        if (!jwtService.validateToken(refreshToken) || !jwtService.isRefreshToken(refreshToken)) {
            throw InvalidTokenException("Invalid refresh token")
        }

        val username = jwtService.getUsernameFromToken(refreshToken)
        
        if (!refreshTokenService.isValidRefreshToken(username, refreshToken)) {
            throw InvalidTokenException("Refresh token not found or expired")
        }

        val userDetails = userService.loadUserByUsername(username)
        val newAccessToken = jwtService.generateAccessToken(userDetails)
        val newRefreshToken = jwtService.generateRefreshToken(username)
        
        // Update refresh token in database
        refreshTokenService.updateRefreshToken(username, refreshToken, newRefreshToken)

        val response = JwtResponse(
            accessToken = newAccessToken,
            refreshToken = newRefreshToken,
            tokenType = "Bearer",
            username = username,
            authorities = userDetails.authorities.map { it.authority }.toSet()
        )

        return ResponseEntity.ok(response)
    }

    @PostMapping("/logout")
    @PreAuthorize("isAuthenticated()")
    fun logout(
        @RequestHeader("Authorization") authHeader: String,
        authentication: Authentication
    ): ResponseEntity<Map<String, String>> {
        val token = authHeader.substring(7)
        val username = authentication.name
        
        // Invalidate refresh tokens
        refreshTokenService.revokeAllRefreshTokens(username)
        
        // Add access token to blacklist (if implementing token blacklisting)
        // tokenBlacklistService.blacklistToken(token)
        
        logger.info("User {} logged out successfully", username)
        return ResponseEntity.ok(mapOf("message" to "Logout successful"))
    }
}
```

---

## Exception Handling

### Custom Exception Classes
```java
// Java
public class AuthenticationException extends RuntimeException {
    public AuthenticationException(String message) {
        super(message);
    }
}

public class InvalidTokenException extends RuntimeException {
    public InvalidTokenException(String message) {
        super(message);
    }
}
```

```kotlin
// Kotlin
class AuthenticationException(message: String) : RuntimeException(message)
class InvalidTokenException(message: String) : RuntimeException(message)
```

### Global Exception Handler
```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ErrorResponse> handleAuthenticationException(AuthenticationException e) {
        logger.warn("Authentication error: {}", e.getMessage());
        ErrorResponse error = new ErrorResponse(
            "AUTHENTICATION_FAILED",
            e.getMessage(),
            Instant.now()
        );
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
    }

    @ExceptionHandler(InvalidTokenException.class)
    public ResponseEntity<ErrorResponse> handleInvalidTokenException(InvalidTokenException e) {
        logger.warn("Invalid token error: {}", e.getMessage());
        ErrorResponse error = new ErrorResponse(
            "INVALID_TOKEN",
            e.getMessage(),
            Instant.now()
        );
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleAccessDeniedException(AccessDeniedException e) {
        logger.warn("Access denied: {}", e.getMessage());
        ErrorResponse error = new ErrorResponse(
            "ACCESS_DENIED",
            "Access denied",
            Instant.now()
        );
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
    }
}
```

### Kotlin Global Exception Handler
```kotlin
@RestControllerAdvice
class GlobalExceptionHandler {

    companion object {
        private val logger = LoggerFactory.getLogger(GlobalExceptionHandler::class.java)
    }

    @ExceptionHandler(AuthenticationException::class)
    fun handleAuthenticationException(e: AuthenticationException): ResponseEntity<ErrorResponse> {
        logger.warn("Authentication error: {}", e.message)
        val error = ErrorResponse(
            code = "AUTHENTICATION_FAILED",
            message = e.message ?: "Authentication failed",
            timestamp = Instant.now()
        )
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error)
    }

    @ExceptionHandler(InvalidTokenException::class)
    fun handleInvalidTokenException(e: InvalidTokenException): ResponseEntity<ErrorResponse> {
        logger.warn("Invalid token error: {}", e.message)
        val error = ErrorResponse(
            code = "INVALID_TOKEN",
            message = e.message ?: "Invalid token",
            timestamp = Instant.now()
        )
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error)
    }

    @ExceptionHandler(AccessDeniedException::class)
    fun handleAccessDeniedException(e: AccessDeniedException): ResponseEntity<ErrorResponse> {
        logger.warn("Access denied: {}", e.message)
        val error = ErrorResponse(
            code = "ACCESS_DENIED",
            message = "Access denied",
            timestamp = Instant.now()
        )
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error)
    }
}
```

### Authentication Entry Point
```java
@Component
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationEntryPoint.class);
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void commence(
        HttpServletRequest request,
        HttpServletResponse response,
        AuthenticationException authException
    ) throws IOException {
        
        logger.error("Unauthorized error: {}", authException.getMessage());

        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);

        ErrorResponse errorResponse = new ErrorResponse(
            "UNAUTHORIZED",
            "Full authentication is required to access this resource",
            Instant.now()
        );

        objectMapper.writeValue(response.getOutputStream(), errorResponse);
    }
}
```

```kotlin
@Component
class JwtAuthenticationEntryPoint : AuthenticationEntryPoint {

    companion object {
        private val logger = LoggerFactory.getLogger(JwtAuthenticationEntryPoint::class.java)
    }

    private val objectMapper = ObjectMapper()

    override fun commence(
        request: HttpServletRequest,
        response: HttpServletResponse,
        authException: AuthenticationException
    ) {
        logger.error("Unauthorized error: {}", authException.message)

        response.contentType = MediaType.APPLICATION_JSON_VALUE
        response.status = HttpServletResponse.SC_UNAUTHORIZED

        val errorResponse = ErrorResponse(
            code = "UNAUTHORIZED",
            message = "Full authentication is required to access this resource",
            timestamp = Instant.now()
        )

        objectMapper.writeValue(response.outputStream, errorResponse)
    }
}
```

---

## Testing Standards

### Unit Tests for JWT Service
```java
@ExtendWith(MockitoExtension.class)
class JwtServiceTest {

    @Mock
    private JwtProperties jwtProperties;

    @InjectMocks
    private JwtService jwtService;

    private UserDetails userDetails;

    @BeforeEach
    void setUp() {
        when(jwtProperties.secret()).thenReturn("mySecretKeyForTesting123456789");
        when(jwtProperties.expirationMs()).thenReturn(3600000L);
        when(jwtProperties.refreshExpirationMs()).thenReturn(86400000L);
        when(jwtProperties.issuer()).thenReturn("test-app");
        when(jwtProperties.audience()).thenReturn("test-users");
        when(jwtProperties.getExpirationDuration()).thenReturn(Duration.ofHours(1));
        when(jwtProperties.getRefreshExpirationDuration()).thenReturn(Duration.ofDays(1));

        userDetails = User.builder()
            .username("testuser")
            .password("password")
            .authorities("ROLE_USER")
            .build();

        // Reinitialize service with mocked properties
        jwtService = new JwtService(jwtProperties);
    }

    @Test
    @DisplayName("Should generate valid access token")
    void shouldGenerateValidAccessToken() {
        // When
        String token = jwtService.generateAccessToken(userDetails);

        // Then
        assertThat(token).isNotNull().isNotEmpty();
        assertThat(jwtService.validateToken(token)).isTrue();
        assertThat(jwtService.getUsernameFromToken(token)).isEqualTo("testuser");
        assertThat(jwtService.isRefreshToken(token)).isFalse();
    }

    @Test
    @DisplayName("Should generate valid refresh token")
    void shouldGenerateValidRefreshToken() {
        // When
        String token = jwtService.generateRefreshToken("testuser");

        // Then
        assertThat(token).isNotNull().isNotEmpty();
        assertThat(jwtService.validateToken(token)).isTrue();
        assertThat(jwtService.getUsernameFromToken(token)).isEqualTo("testuser");
        assertThat(jwtService.isRefreshToken(token)).isTrue();
    }

    @Test
    @DisplayName("Should reject invalid token")
    void shouldRejectInvalidToken() {
        // Given
        String invalidToken = "invalid.token.here";

        // When & Then
        assertThat(jwtService.validateToken(invalidToken)).isFalse();
    }

    @Test
    @DisplayName("Should extract authorities from token")
    void shouldExtractAuthoritiesFromToken() {
        // Given
        String token = jwtService.generateAccessToken(userDetails);

        // When
        Collection<String> authorities = jwtService.getAuthoritiesFromToken(token);

        // Then
        assertThat(authorities).containsExactly("ROLE_USER");
    }
}
```

### Integration Tests
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
class AuthControllerIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
        
        User user = new User();
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setPassword(passwordEncoder.encode("password123"));
        user.setRoles(Set.of(new Role("ROLE_USER")));
        userRepository.save(user);
    }

    @Test
    @DisplayName("Should authenticate user with valid credentials")
    void shouldAuthenticateUserWithValidCredentials() {
        // Given
        LoginRequest request = new LoginRequest("testuser", "password123");

        // When
        ResponseEntity<JwtResponse> response = restTemplate.postForEntity(
            "/api/auth/login", request, JwtResponse.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().accessToken()).isNotNull();
        assertThat(response.getBody().refreshToken()).isNotNull();
        assertThat(response.getBody().username()).isEqualTo("testuser");
    }

    @Test
    @DisplayName("Should reject invalid credentials")
    void shouldRejectInvalidCredentials() {
        // Given
        LoginRequest request = new LoginRequest("testuser", "wrongpassword");

        // When
        ResponseEntity<ErrorResponse> response = restTemplate.postForEntity(
            "/api/auth/login", request, ErrorResponse.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("AUTHENTICATION_FAILED");
    }

    @Test
    @DisplayName("Should access protected endpoint with valid token")
    void shouldAccessProtectedEndpointWithValidToken() {
        // Given
        LoginRequest loginRequest = new LoginRequest("testuser", "password123");
        ResponseEntity<JwtResponse> loginResponse = restTemplate.postForEntity(
            "/api/auth/login", loginRequest, JwtResponse.class
        );
        
        String token = loginResponse.getBody().accessToken();
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(token);
        HttpEntity<String> entity = new HttpEntity<>(headers);

        // When
        ResponseEntity<String> response = restTemplate.exchange(
            "/api/users/me", HttpMethod.GET, entity, String.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }
}
```

---

## Security Hardening

### Security Headers Configuration
```java
@Configuration
public class SecurityHeadersConfig {

    @Bean
    public FilterRegistrationBean<SecurityHeadersFilter> securityHeadersFilter() {
        FilterRegistrationBean<SecurityHeadersFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new SecurityHeadersFilter());
        registrationBean.addUrlPatterns("/api/*");
        registrationBean.setOrder(1);
        return registrationBean;
    }

    public static class SecurityHeadersFilter implements Filter {
        @Override
        public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
                throws IOException, ServletException {
            
            HttpServletResponse httpResponse = (HttpServletResponse) response;
            
            // Prevent clickjacking
            httpResponse.setHeader("X-Frame-Options", "DENY");
            
            // Prevent MIME type sniffing
            httpResponse.setHeader("X-Content-Type-Options", "nosniff");
            
            // XSS protection
            httpResponse.setHeader("X-XSS-Protection", "1; mode=block");
            
            // Referrer policy
            httpResponse.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
            
            // Content Security Policy
            httpResponse.setHeader("Content-Security-Policy", 
                "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'");
            
            chain.doFilter(request, response);
        }
    }
}
```

### Rate Limiting Configuration
```java
@Configuration
public class RateLimitingConfig {

    @Bean
    public FilterRegistrationBean<RateLimitingFilter> rateLimitingFilter() {
        FilterRegistrationBean<RateLimitingFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new RateLimitingFilter());
        registrationBean.addUrlPatterns("/api/auth/*");
        registrationBean.setOrder(2);
        return registrationBean;
    }

    public static class RateLimitingFilter implements Filter {
        private final Map<String, List<Long>> requestCounts = new ConcurrentHashMap<>();
        private final int maxRequests = 5; // 5 requests per minute
        private final long timeWindow = 60000; // 1 minute

        @Override
        public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
                throws IOException, ServletException {
            
            HttpServletRequest httpRequest = (HttpServletRequest) request;
            String clientIp = getClientIpAddress(httpRequest);
            
            if (isRateLimited(clientIp)) {
                HttpServletResponse httpResponse = (HttpServletResponse) response;
                httpResponse.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
                httpResponse.getWriter().write("{\"error\":\"Rate limit exceeded\"}");
                return;
            }
            
            chain.doFilter(request, response);
        }

        private boolean isRateLimited(String clientIp) {
            long currentTime = System.currentTimeMillis();
            requestCounts.computeIfAbsent(clientIp, k -> new ArrayList<>());
            
            List<Long> timestamps = requestCounts.get(clientIp);
            
            // Remove old entries
            timestamps.removeIf(timestamp -> currentTime - timestamp > timeWindow);
            
            if (timestamps.size() >= maxRequests) {
                return true;
            }
            
            timestamps.add(currentTime);
            return false;
        }

        private String getClientIpAddress(HttpServletRequest request) {
            String xForwardedFor = request.getHeader("X-Forwarded-For");
            if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
                return xForwardedFor.split(",")[0].trim();
            }
            return request.getRemoteAddr();
        }
    }
}
```

### Password Policy Configuration
```java
@Component
public class PasswordPolicyValidator {

    private static final String PASSWORD_PATTERN = 
        "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#&()–[{}]:;',?/*~$^+=<>]).{8,}$";
    
    private static final Pattern pattern = Pattern.compile(PASSWORD_PATTERN);

    public boolean isValid(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        
        return pattern.matcher(password).matches();
    }

    public List<String> getViolations(String password) {
        List<String> violations = new ArrayList<>();
        
        if (password == null || password.length() < 8) {
            violations.add("Password must be at least 8 characters long");
        }
        
        if (!password.matches(".*[0-9].*")) {
            violations.add("Password must contain at least one digit");
        }
        
        if (!password.matches(".*[a-z].*")) {
            violations.add("Password must contain at least one lowercase letter");
        }
        
        if (!password.matches(".*[A-Z].*")) {
            violations.add("Password must contain at least one uppercase letter");
        }
        
        if (!password.matches(".*[!@#&()–\\[{}\\]:;',?/*~$^+=<>].*")) {
            violations.add("Password must contain at least one special character");
        }
        
        return violations;
    }
}
```

---

## Validation Checklist

### ✅ Configuration Compliance
- [ ] JWT secret is externalized and secure (minimum 256 bits)
- [ ] Token expiration times are appropriate (access: 15-60 min, refresh: 1-7 days)
- [ ] HTTPS enforced in production environments
- [ ] CORS properly configured for production
- [ ] Security headers properly set
- [ ] Rate limiting implemented for authentication endpoints

### ✅ JWT Implementation Compliance
- [ ] Using latest JJWT library (0.12.x)
- [ ] Proper signature algorithm (HS512 or RS256)
- [ ] Claims validation (issuer, audience, expiration)
- [ ] Token type distinction (access vs refresh)
- [ ] Proper error handling for token validation
- [ ] No sensitive data in JWT payload

### ✅ Security Configuration Compliance
- [ ] Method-level security enabled (@PreAuthorize, @PostAuthorize)
- [ ] Stateless session management
- [ ] Proper exception handling (AuthenticationEntryPoint, AccessDeniedHandler)
- [ ] CSRF disabled for stateless APIs
- [ ] Password encoder with sufficient strength (BCrypt strength 12+)
- [ ] Authentication manager properly configured

### ✅ Filter Implementation Compliance
- [ ] JWT filter extends OncePerRequestFilter
- [ ] Proper token extraction from Authorization header
- [ ] Bearer token format validation
- [ ] Refresh tokens not accepted for authentication
- [ ] Security context properly set and cleared
- [ ] Exception handling in filter chain

### ✅ Controller Implementation Compliance
- [ ] Input validation with @Valid annotations
- [ ] Proper HTTP status codes for responses
- [ ] Refresh token mechanism implemented
- [ ] Logout functionality clears tokens
- [ ] Error responses are consistent and informative
- [ ] No password exposure in responses

### ✅ Testing Compliance
- [ ] Unit tests for JWT service (token generation, validation, extraction)
- [ ] Integration tests for authentication endpoints
- [ ] Security tests for protected endpoints
- [ ] Negative test cases (invalid tokens, expired tokens)
- [ ] Rate limiting tests
- [ ] CORS tests for allowed/disallowed origins

### ✅ Security Hardening Compliance
- [ ] Password policy enforcement
- [ ] Account lockout mechanism
- [ ] Rate limiting on authentication endpoints
- [ ] Security headers implementation
- [ ] Input sanitization and validation
- [ ] Audit logging for security events
- [ ] Token blacklisting mechanism (optional but recommended)

### ✅ Production Readiness Compliance
- [ ] Environment-specific configuration
- [ ] Proper logging levels configured
- [ ] Health checks exclude sensitive endpoints
- [ ] Monitoring and alerting for security events
- [ ] Regular security dependency updates
- [ ] SSL/TLS configuration validated

---

## Reference URLs for Claude Code

### Official Documentation
- **Spring Security**: https://docs.spring.io/spring-security/reference/
- **Spring Boot Security**: https://docs.spring.io/spring-boot/docs/current/reference/html/web.html#web.security
- **JWT.io**: https://jwt.io/
- **JJWT Library**: https://github.com/jwtk/jjwt

### Security Best Practices
- **OWASP JWT Security**: https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html
- **Spring Security Architecture**: https://spring.io/guides/topicals/spring-security-architecture
- **OWASP Top 10**: https://owasp.org/www-project-top-ten/

### Testing Resources
- **Spring Security Test**: https://docs.spring.io/spring-security/reference/servlet/test/index.html
- **Testcontainers**: https://www.testcontainers.org/
- **Spring Boot Test**: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing

### Performance and Security
- **Spring Security Performance**: https://docs.spring.io/spring-security/reference/servlet/architecture.html#servlet-security-filters
- **JWT Best Practices**: https://auth0.com/blog/a-look-at-the-latest-draft-for-jwt-bcp/
- **Spring Boot Actuator Security**: https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.endpoints.security

---

**Note**: This comprehensive document serves as the authoritative guide for JWT security implementation with Spring Boot using both Java and Kotlin. It should be referenced for all JWT-based authentication projects to ensure consistent implementation and adherence to security best practices. The validation checklist can be used by Claude Code for automated project analysis and security compliance verification.