# JWT Authentication Component - Claude Code Instructions

## CONTEXT
- **Project Type**: component
- **Complexity**: medium
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Technology Stack
- **Backend**: Spring Boot + Spring Security
- **Frontend**: React/Next.js + Axios
- **Token Type**: JWT (JSON Web Token)
- **Storage**: HTTP-only cookies + localStorage (refresh token)
- **Security**: CSRF protection, secure headers

### Component Features
- User login/logout functionality
- Automatic token refresh
- Protected route handling
- Token validation and expiry management
- Secure token storage

## IMPLEMENTATION STRATEGY

### 1. Backend JWT Configuration
**JWT Service**: `src/main/kotlin/service/JwtService.kt`
```kotlin
@Service
class JwtService {
    @Value("\${jwt.secret}")
    private val secret: String = ""
    
    @Value("\${jwt.expiration:3600000}")
    private val expiration: Long = 3600000
    
    fun generateToken(username: String): String {
        return Jwts.builder()
            .setSubject(username)
            .setIssuedAt(Date())
            .setExpiration(Date(System.currentTimeMillis() + expiration))
            .signWith(SignatureAlgorithm.HS256, secret)
            .compact()
    }
    
    fun validateToken(token: String): Boolean {
        return try {
            Jwts.parser().setSigningKey(secret).parseClaimsJws(token)
            true
        } catch (e: Exception) {
            false
        }
    }
    
    fun getUsernameFromToken(token: String): String {
        return Jwts.parser()
            .setSigningKey(secret)
            .parseClaimsJws(token)
            .body
            .subject
    }
}
```

### 2. Spring Security Configuration
**Security Config**: `src/main/kotlin/config/SecurityConfig.kt`
```kotlin
@Configuration
@EnableWebSecurity
class SecurityConfig {
    
    @Autowired
    private lateinit var jwtAuthenticationEntryPoint: JwtAuthenticationEntryPoint
    
    @Autowired
    private lateinit var jwtRequestFilter: JwtRequestFilter
    
    @Bean
    fun passwordEncoder(): PasswordEncoder = BCryptPasswordEncoder()
    
    @Bean
    fun authenticationManager(
        authConfig: AuthenticationConfiguration
    ): AuthenticationManager = authConfig.authenticationManager
    
    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        http.csrf { it.disable() }
            .authorizeHttpRequests { authz ->
                authz
                    .requestMatchers("/api/auth/**").permitAll()
                    .requestMatchers("/api/public/**").permitAll()
                    .anyRequest().authenticated()
            }
            .exceptionHandling { it.authenticationEntryPoint(jwtAuthenticationEntryPoint) }
            .sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }
            
        http.addFilterBefore(jwtRequestFilter, UsernamePasswordAuthenticationFilter::class.java)
        return http.build()
    }
}
```

### 3. JWT Request Filter
**JWT Filter**: `src/main/kotlin/security/JwtRequestFilter.kt`
```kotlin
@Component
class JwtRequestFilter : OncePerRequestFilter() {
    
    @Autowired
    private lateinit var userDetailsService: UserDetailsService
    
    @Autowired
    private lateinit var jwtService: JwtService
    
    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        chain: FilterChain
    ) {
        val requestTokenHeader = request.getHeader("Authorization")
        
        var username: String? = null
        var jwtToken: String? = null
        
        if (requestTokenHeader?.startsWith("Bearer ") == true) {
            jwtToken = requestTokenHeader.substring(7)
            try {
                username = jwtService.getUsernameFromToken(jwtToken)
            } catch (e: Exception) {
                logger.error("Unable to get JWT Token", e)
            }
        }
        
        if (username != null && SecurityContextHolder.getContext().authentication == null) {
            val userDetails = userDetailsService.loadUserByUsername(username)
            
            if (jwtService.validateToken(jwtToken!!)) {
                val authToken = UsernamePasswordAuthenticationToken(
                    userDetails, null, userDetails.authorities
                )
                authToken.details = WebAuthenticationDetailsSource().buildDetails(request)
                SecurityContextHolder.getContext().authentication = authToken
            }
        }
        chain.doFilter(request, response)
    }
}
```

### 4. Authentication Controller
**Auth Controller**: `src/main/kotlin/controller/AuthController.kt`
```kotlin
@RestController
@RequestMapping("/api/auth")
class AuthController {
    
    @Autowired
    private lateinit var authenticationManager: AuthenticationManager
    
    @Autowired
    private lateinit var jwtService: JwtService
    
    @Autowired
    private lateinit var userService: UserService
    
    @PostMapping("/login")
    fun login(@RequestBody loginRequest: LoginRequest): ResponseEntity<JwtResponse> {
        try {
            authenticationManager.authenticate(
                UsernamePasswordAuthenticationToken(
                    loginRequest.username,
                    loginRequest.password
                )
            )
            
            val token = jwtService.generateToken(loginRequest.username)
            val user = userService.findByUsername(loginRequest.username)
            
            return ResponseEntity.ok(JwtResponse(
                token = token,
                type = "Bearer",
                username = user?.username,
                email = user?.email,
                roles = user?.roles?.map { it.name } ?: emptyList()
            ))
        } catch (e: BadCredentialsException) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build()
        }
    }
    
    @PostMapping("/refresh")
    fun refreshToken(@RequestBody refreshRequest: RefreshTokenRequest): ResponseEntity<JwtResponse> {
        // Implement refresh token logic
        return ResponseEntity.ok().build()
    }
    
    @PostMapping("/logout")
    fun logout(): ResponseEntity<String> {
        SecurityContextHolder.clearContext()
        return ResponseEntity.ok("Logged out successfully")
    }
}
```

### 5. Frontend Authentication Context
**Auth Context**: `src/contexts/AuthContext.js`
```javascript
import { createContext, useContext, useReducer, useEffect } from 'react';
import authService from '../services/authService';

const AuthContext = createContext();

const initialState = {
  user: null,
  token: null,
  isAuthenticated: false,
  loading: true,
};

function authReducer(state, action) {
  switch (action.type) {
    case 'LOGIN_SUCCESS':
      return {
        ...state,
        user: action.payload.user,
        token: action.payload.token,
        isAuthenticated: true,
        loading: false,
      };
    case 'LOGOUT':
      return {
        ...state,
        user: null,
        token: null,
        isAuthenticated: false,
        loading: false,
      };
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    default:
      return state;
  }
}

export function AuthProvider({ children }) {
  const [state, dispatch] = useReducer(authReducer, initialState);

  useEffect(() => {
    const initAuth = async () => {
      const token = localStorage.getItem('auth_token');
      if (token) {
        try {
          const user = await authService.getCurrentUser();
          dispatch({
            type: 'LOGIN_SUCCESS',
            payload: { user, token },
          });
        } catch (error) {
          localStorage.removeItem('auth_token');
          dispatch({ type: 'SET_LOADING', payload: false });
        }
      } else {
        dispatch({ type: 'SET_LOADING', payload: false });
      }
    };

    initAuth();
  }, []);

  const login = async (username, password) => {
    try {
      const response = await authService.login(username, password);
      localStorage.setItem('auth_token', response.token);
      dispatch({
        type: 'LOGIN_SUCCESS',
        payload: { user: response, token: response.token },
      });
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  };

  const logout = () => {
    localStorage.removeItem('auth_token');
    authService.logout();
    dispatch({ type: 'LOGOUT' });
  };

  return (
    <AuthContext.Provider value={{ ...state, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
```

### 6. Authentication Service
**Auth Service**: `src/services/authService.js`
```javascript
import api from './api';

const authService = {
  async login(username, password) {
    const response = await api.post('/auth/login', {
      username,
      password,
    });
    return response;
  },

  async logout() {
    try {
      await api.post('/auth/logout');
    } catch (error) {
      console.error('Logout error:', error);
    }
  },

  async getCurrentUser() {
    const response = await api.get('/auth/me');
    return response;
  },

  async refreshToken() {
    const response = await api.post('/auth/refresh');
    return response;
  },
};

export default authService;
```

### 7. Protected Route Component
**Protected Route**: `src/components/auth/ProtectedRoute.js`
```javascript
import { useAuth } from '../../contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import Loading from '../common/Loading';

export default function ProtectedRoute({ children }) {
  const { isAuthenticated, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !isAuthenticated) {
      router.push('/login');
    }
  }, [isAuthenticated, loading, router]);

  if (loading) {
    return <Loading />;
  }

  if (!isAuthenticated) {
    return null;
  }

  return children;
}
```

### 8. Login Component
**Login Form**: `src/components/auth/LoginForm.js`
```javascript
import { useState } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import { useRouter } from 'next/navigation';
import {
  Box,
  TextField,
  Button,
  Paper,
  Typography,
  Alert,
} from '@mui/material';

export default function LoginForm() {
  const [credentials, setCredentials] = useState({
    username: '',
    password: '',
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const router = useRouter();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    const result = await login(credentials.username, credentials.password);
    
    if (result.success) {
      router.push('/dashboard');
    } else {
      setError(result.error || 'Login failed');
    }
    setLoading(false);
  };

  return (
    <Box display="flex" justifyContent="center" alignItems="center" minHeight="100vh">
      <Paper elevation={3} sx={{ p: 4, maxWidth: 400, width: '100%' }}>
        <Typography variant="h4" component="h1" gutterBottom align="center">
          Login
        </Typography>
        
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
        
        <form onSubmit={handleSubmit}>
          <TextField
            fullWidth
            label="Username"
            value={credentials.username}
            onChange={(e) => setCredentials({ ...credentials, username: e.target.value })}
            margin="normal"
            required
          />
          <TextField
            fullWidth
            label="Password"
            type="password"
            value={credentials.password}
            onChange={(e) => setCredentials({ ...credentials, password: e.target.value })}
            margin="normal"
            required
          />
          <Button
            type="submit"
            fullWidth
            variant="contained"
            sx={{ mt: 3, mb: 2 }}
            disabled={loading}
          >
            {loading ? 'Signing In...' : 'Sign In'}
          </Button>
        </form>
      </Paper>
    </Box>
  );
}
```

## CLAUDE_CODE_COMMANDS

### Backend Configuration
```bash
# Add JWT dependencies to build.gradle.kts
implementation("io.jsonwebtoken:jjwt:0.9.1")
implementation("org.springframework.boot:spring-boot-starter-security")

# Set JWT properties in application.yml
jwt:
  secret: your-secret-key
  expiration: 3600000
```

### Frontend Setup
```bash
# Install authentication dependencies
npm install axios

# Add environment variables
NEXT_PUBLIC_API_URL=http://localhost:8080/api
```

### Testing Commands
```bash
# Test authentication endpoints
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user","password":"password"}'

# Test protected endpoint
curl -X GET http://localhost:8080/api/protected \
  -H "Authorization: Bearer <token>"
```

## VALIDATION_CHECKLIST
- [ ] JWT token generation and validation working
- [ ] Spring Security configuration properly set up
- [ ] Frontend authentication context implemented
- [ ] Protected routes redirect to login when unauthorized
- [ ] Token refresh mechanism implemented
- [ ] Secure token storage (HTTP-only cookies for sensitive data)
- [ ] Login/logout functionality working
- [ ] Error handling for authentication failures
- [ ] CSRF protection enabled
- [ ] API endpoints properly secured