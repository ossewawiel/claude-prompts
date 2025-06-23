# Spring Security Integration - Claude Code Instructions

## CONTEXT
- **Project Type**: component
- **Complexity**: advanced
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Technology Stack
- **Framework**: Spring Boot 3.2+ with Spring Security 6+
- **Authentication**: JWT tokens, username/password, OAuth2
- **Authorization**: Role-based access control (RBAC)
- **Password**: BCrypt encoding
- **CORS**: Cross-origin resource sharing
- **CSRF**: Protection for state-changing operations

### Security Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Security      │ ─→ │  Authentication │ ─→ │  Authorization  │
│   Filter Chain  │    │   Manager       │    │   Manager       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   JWT Filter    │    │  User Details   │    │  Method Level   │
│   CORS Filter   │    │   Service       │    │   Security      │
│   CSRF Filter   │    │   Provider      │    │   Annotations   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## IMPLEMENTATION STRATEGY

### 1. Security Configuration
**Main Security Config**: `src/main/java/config/SecurityConfig.java`
```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    private final JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    private final JwtRequestFilter jwtRequestFilter;
    private final UserDetailsService userDetailsService;

    public SecurityConfig(
        JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint,
        JwtRequestFilter jwtRequestFilter,
        UserDetailsService userDetailsService
    ) {
        this.jwtAuthenticationEntryPoint = jwtAuthenticationEntryPoint;
        this.jwtRequestFilter = jwtRequestFilter;
        this.userDetailsService = userDetailsService;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    @Bean
    public AuthenticationManager authenticationManager(
        AuthenticationConfiguration config
    ) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .exceptionHandling(exceptions -> 
                exceptions.authenticationEntryPoint(jwtAuthenticationEntryPoint)
            )
            .authorizeHttpRequests(authz -> authz
                // Public endpoints
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                .requestMatchers("/actuator/health", "/actuator/info").permitAll()
                
                // Admin endpoints
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/**").hasRole("ADMIN")
                
                // User endpoints
                .requestMatchers("/api/users/**").hasAnyRole("USER", "ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/**").hasAnyRole("USER", "ADMIN")
                .requestMatchers(HttpMethod.PUT, "/api/**").hasAnyRole("USER", "ADMIN")
                
                // All other requests require authentication
                .anyRequest().authenticated()
            );

        http.authenticationProvider(authenticationProvider());
        http.addFilterBefore(jwtRequestFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList(
            "http://localhost:3000",
            "https://*.yourdomain.com"
        ));
        configuration.setAllowedMethods(Arrays.asList(
            "GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"
        ));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", configuration);
        return source;
    }
}
```

### 2. User Details Service
**Custom User Details**: `src/main/java/security/UserDetailsImpl.java`
```java
public class UserDetailsImpl implements UserDetails {
    private final Long id;
    private final String username;
    private final String email;
    private final String password;
    private final Collection<? extends GrantedAuthority> authorities;
    private final boolean enabled;
    private final boolean accountNonExpired;
    private final boolean accountNonLocked;
    private final boolean credentialsNonExpired;

    public UserDetailsImpl(
        Long id, String username, String email, String password,
        Collection<? extends GrantedAuthority> authorities,
        boolean enabled, boolean accountNonExpired,
        boolean accountNonLocked, boolean credentialsNonExpired
    ) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.password = password;
        this.authorities = authorities;
        this.enabled = enabled;
        this.accountNonExpired = accountNonExpired;
        this.accountNonLocked = accountNonLocked;
        this.credentialsNonExpired = credentialsNonExpired;
    }

    public static UserDetailsImpl build(User user) {
        List<GrantedAuthority> authorities = user.getRoles().stream()
            .map(role -> new SimpleGrantedAuthority("ROLE_" + role.getName()))
            .collect(Collectors.toList());

        return new UserDetailsImpl(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getPassword(),
            authorities,
            user.getStatus() == UserStatus.ACTIVE,
            true, // accountNonExpired
            user.getStatus() != UserStatus.SUSPENDED, // accountNonLocked
            true  // credentialsNonExpired
        );
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return accountNonExpired;
    }

    @Override
    public boolean isAccountNonLocked() {
        return accountNonLocked;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return credentialsNonExpired;
    }

    @Override
    public boolean isEnabled() {
        return enabled;
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }
}
```

**User Details Service**: `src/main/java/security/UserDetailsServiceImpl.java`
```java
@Service
@Transactional(readOnly = true)
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserRepository userRepository;
    private final Logger logger = LoggerFactory.getLogger(UserDetailsServiceImpl.class);

    public UserDetailsServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        logger.debug("Loading user by username: {}", username);
        
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));

        return UserDetailsImpl.build(user);
    }
}
```

### 3. JWT Components
**JWT Utils**: `src/main/java/security/JwtUtils.java`
```java
@Component
public class JwtUtils {
    private static final Logger logger = LoggerFactory.getLogger(JwtUtils.class);

    @Value("${app.jwtSecret}")
    private String jwtSecret;

    @Value("${app.jwtExpirationMs}")
    private int jwtExpirationMs;

    public String generateJwtToken(Authentication authentication) {
        UserDetailsImpl userPrincipal = (UserDetailsImpl) authentication.getPrincipal();

        return Jwts.builder()
            .setSubject(userPrincipal.getUsername())
            .claim("userId", userPrincipal.getId())
            .claim("email", userPrincipal.getEmail())
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + jwtExpirationMs))
            .signWith(SignatureAlgorithm.HS256, jwtSecret)
            .compact();
    }

    public String getUserNameFromJwtToken(String token) {
        return Jwts.parser()
            .setSigningKey(jwtSecret)
            .parseClaimsJws(token)
            .getBody()
            .getSubject();
    }

    public boolean validateJwtToken(String authToken) {
        try {
            Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(authToken);
            return true;
        } catch (SignatureException e) {
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
}
```

**JWT Request Filter**: `src/main/java/security/JwtRequestFilter.java`
```java
@Component
public class JwtRequestFilter extends OncePerRequestFilter {
    
    private final UserDetailsService userDetailsService;
    private final JwtUtils jwtUtils;
    private final Logger logger = LoggerFactory.getLogger(JwtRequestFilter.class);

    public JwtRequestFilter(UserDetailsService userDetailsService, JwtUtils jwtUtils) {
        this.userDetailsService = userDetailsService;
        this.jwtUtils = jwtUtils;
    }

    @Override
    protected void doFilterInternal(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain
    ) throws ServletException, IOException {
        
        String jwt = parseJwt(request);
        
        if (jwt != null && jwtUtils.validateJwtToken(jwt)) {
            String username = jwtUtils.getUserNameFromJwtToken(jwt);

            UserDetails userDetails = userDetailsService.loadUserByUsername(username);
            UsernamePasswordAuthenticationToken authentication = 
                new UsernamePasswordAuthenticationToken(
                    userDetails, null, userDetails.getAuthorities()
                );
            authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

            SecurityContextHolder.getContext().setAuthentication(authentication);
        }

        filterChain.doFilter(request, response);
    }

    private String parseJwt(HttpServletRequest request) {
        String headerAuth = request.getHeader("Authorization");

        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            return headerAuth.substring(7);
        }

        return null;
    }
}
```

### 4. Authentication Entry Point
**JWT Entry Point**: `src/main/java/security/JwtAuthenticationEntryPoint.java`
```java
@Component
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private final Logger logger = LoggerFactory.getLogger(JwtAuthenticationEntryPoint.class);

    @Override
    public void commence(
        HttpServletRequest request,
        HttpServletResponse response,
        AuthenticationException authException
    ) throws IOException {
        
        logger.error("Unauthorized error: {}", authException.getMessage());

        response.setContentType("application/json");
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);

        final ObjectMapper mapper = new ObjectMapper();
        final Map<String, Object> body = new HashMap<>();
        body.put("status", HttpServletResponse.SC_UNAUTHORIZED);
        body.put("error", "Unauthorized");
        body.put("message", authException.getMessage());
        body.put("path", request.getServletPath());
        body.put("timestamp", Instant.now().toString());

        mapper.writeValue(response.getOutputStream(), body);
    }
}
```

### 5. Method Level Security
**Service with Security Annotations**: `src/main/java/service/SecureUserService.java`
```java
@Service
@Transactional
public class SecureUserService {

    private final UserRepository userRepository;

    public SecureUserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @PreAuthorize("hasRole('ADMIN')")
    public List<UserDto> getAllUsers() {
        return userRepository.findAll().stream()
            .map(UserDto::new)
            .collect(Collectors.toList());
    }

    @PreAuthorize("hasRole('ADMIN') or authentication.name == #username")
    public UserDto getUserByUsername(String username) {
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new EntityNotFoundException("User not found"));
        return new UserDto(user);
    }

    @PreAuthorize("hasRole('ADMIN') or @userService.isOwner(authentication.name, #userId)")
    public UserDto updateUser(Long userId, UpdateUserRequest request) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new EntityNotFoundException("User not found"));
        
        // Update user logic
        return new UserDto(user);
    }

    @PostAuthorize("hasRole('ADMIN') or returnObject.username == authentication.name")
    public UserDto getUserById(Long id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new EntityNotFoundException("User not found"));
        return new UserDto(user);
    }

    public boolean isOwner(String username, Long userId) {
        return userRepository.findById(userId)
            .map(user -> user.getUsername().equals(username))
            .orElse(false);
    }
}
```

### 6. Security Utilities
**Security Context Helper**: `src/main/java/security/SecurityUtils.java`
```java
@Component
public class SecurityUtils {

    public static Optional<String> getCurrentUserLogin() {
        SecurityContext securityContext = SecurityContextHolder.getContext();
        return Optional.ofNullable(extractPrincipal(securityContext.getAuthentication()));
    }

    public static Optional<UserDetailsImpl> getCurrentUser() {
        SecurityContext securityContext = SecurityContextHolder.getContext();
        Authentication authentication = securityContext.getAuthentication();
        
        if (authentication != null && authentication.getPrincipal() instanceof UserDetailsImpl) {
            return Optional.of((UserDetailsImpl) authentication.getPrincipal());
        }
        return Optional.empty();
    }

    public static boolean hasCurrentUserRole(String role) {
        return getCurrentUser()
            .map(user -> user.getAuthorities().stream()
                .anyMatch(auth -> auth.getAuthority().equals("ROLE_" + role)))
            .orElse(false);
    }

    public static boolean hasCurrentUserAnyRole(String... roles) {
        return Arrays.stream(roles)
            .anyMatch(SecurityUtils::hasCurrentUserRole);
    }

    private static String extractPrincipal(Authentication authentication) {
        if (authentication == null) {
            return null;
        } else if (authentication.getPrincipal() instanceof UserDetailsImpl) {
            UserDetailsImpl springSecurityUser = (UserDetailsImpl) authentication.getPrincipal();
            return springSecurityUser.getUsername();
        } else if (authentication.getPrincipal() instanceof String) {
            return (String) authentication.getPrincipal();
        }
        return null;
    }
}
```

### 7. Configuration Properties
**Application Properties**: `application.yml`
```yaml
app:
  jwtSecret: mySecretKey
  jwtExpirationMs: 86400000 # 24 hours

spring:
  security:
    oauth2:
      client:
        registration:
          google:
            client-id: ${GOOGLE_CLIENT_ID}
            client-secret: ${GOOGLE_CLIENT_SECRET}
            scope:
              - email
              - profile

logging:
  level:
    org.springframework.security: DEBUG
    com.company.app.security: DEBUG
```

## CLAUDE_CODE_COMMANDS

### Security Testing
```bash
# Test authentication endpoint
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user","password":"password"}'

# Test protected endpoint
curl -X GET http://localhost:8080/api/users \
  -H "Authorization: Bearer <jwt-token>"

# Test unauthorized access
curl -X GET http://localhost:8080/api/admin/users \
  -H "Authorization: Bearer <user-token>"
```

### Security Configuration
```bash
# Generate secure JWT secret
openssl rand -base64 64

# Test password encoding
java -cp "spring-security-crypto.jar" \
  org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder "password"
```

### Debug Security
```bash
# Enable security debug logging
./gradlew bootRun --args='--logging.level.org.springframework.security=DEBUG'

# Check security filter chain
./gradlew bootRun --args='--debug'
```

## VALIDATION_CHECKLIST
- [ ] Password encoding with BCrypt properly configured
- [ ] JWT token generation and validation working
- [ ] Authentication entry point handling unauthorized requests
- [ ] CORS configuration allows frontend origins
- [ ] Method level security annotations working
- [ ] Role-based access control implemented
- [ ] Security filter chain configured correctly
- [ ] User details service loading user data
- [ ] Authentication manager configured with provider
- [ ] Security utilities for context access working