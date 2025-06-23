# Next.js Spring Boot Integration Pattern - Claude Code Instructions

## CONTEXT
- **Project Type**: pattern
- **Complexity**: medium
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Technology Stack
- **Frontend**: Next.js 14+ (JavaScript) + MUI
- **Backend**: Spring Boot 3+ (Kotlin/Java)
- **Communication**: REST API + JSON
- **Authentication**: JWT tokens
- **CORS**: Properly configured cross-origin requests
- **Environment**: Development + Production deployment

### Integration Architecture
```
┌─────────────────┐    HTTP/REST     ┌─────────────────┐    JDBC     ┌─────────────┐
│   Next.js App  │ ←───────────────→ │  Spring Boot    │ ←──────────→ │  Database   │
│   (Port 3000)  │   JSON Payload   │   (Port 8080)   │             │(PostgreSQL) │
│   - React UI    │                  │   - REST API    │             │             │
│   - MUI Theme   │                  │   - JWT Auth    │             │             │
│   - State Mgmt  │                  │   - Business    │             │             │
└─────────────────┘                  └─────────────────┘             └─────────────┘
```

## IMPLEMENTATION STRATEGY

### 1. Backend CORS Configuration
**CORS Config**: `src/main/kotlin/config/CorsConfig.kt`
```kotlin
@Configuration
@EnableWebMvc
class CorsConfig : WebMvcConfigurer {
    
    override fun addCorsMappings(registry: CorsRegistry) {
        registry.addMapping("/api/**")
            .allowedOrigins(
                "http://localhost:3000",
                "https://yourdomain.com"
            )
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
            .allowedHeaders("*")
            .allowCredentials(true)
            .maxAge(3600)
    }
}
```

### 2. Backend DTO Pattern
**Response DTO**: `src/main/kotlin/dto/ApiResponse.kt`
```kotlin
data class ApiResponse<T>(
    val success: Boolean,
    val data: T? = null,
    val message: String? = null,
    val errors: List<String>? = null,
    val timestamp: Long = System.currentTimeMillis()
)

data class PagedResponse<T>(
    val content: List<T>,
    val page: Int,
    val size: Int,
    val totalElements: Long,
    val totalPages: Int,
    val last: Boolean
)
```

### 3. REST Controller Pattern
**Example Controller**: `src/main/kotlin/controller/UserController.kt`
```kotlin
@RestController
@RequestMapping("/api/users")
class UserController {
    
    @Autowired
    private lateinit var userService: UserService
    
    @GetMapping
    fun getAllUsers(
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "10") size: Int
    ): ResponseEntity<ApiResponse<PagedResponse<UserDto>>> {
        val users = userService.getAllUsers(page, size)
        return ResponseEntity.ok(
            ApiResponse(
                success = true,
                data = users
            )
        )
    }
    
    @GetMapping("/{id}")
    fun getUserById(@PathVariable id: Long): ResponseEntity<ApiResponse<UserDto>> {
        return try {
            val user = userService.getUserById(id)
            ResponseEntity.ok(
                ApiResponse(success = true, data = user)
            )
        } catch (e: UserNotFoundException) {
            ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                ApiResponse(success = false, message = e.message)
            )
        }
    }
    
    @PostMapping
    fun createUser(@Valid @RequestBody userRequest: CreateUserRequest): ResponseEntity<ApiResponse<UserDto>> {
        val user = userService.createUser(userRequest)
        return ResponseEntity.status(HttpStatus.CREATED).body(
            ApiResponse(success = true, data = user)
        )
    }
    
    @PutMapping("/{id}")
    fun updateUser(
        @PathVariable id: Long,
        @Valid @RequestBody userRequest: UpdateUserRequest
    ): ResponseEntity<ApiResponse<UserDto>> {
        val user = userService.updateUser(id, userRequest)
        return ResponseEntity.ok(
            ApiResponse(success = true, data = user)
        )
    }
    
    @DeleteMapping("/{id}")
    fun deleteUser(@PathVariable id: Long): ResponseEntity<ApiResponse<String>> {
        userService.deleteUser(id)
        return ResponseEntity.ok(
            ApiResponse(success = true, message = "User deleted successfully")
        )
    }
}
```

### 4. Frontend API Client Configuration
**API Client**: `src/services/api.js`
```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => {
    // Return the data property if it exists (unwrap ApiResponse)
    return response.data.data !== undefined ? response.data : response.data;
  },
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('auth_token');
      window.location.href = '/login';
    }
    
    // Extract error message from backend response
    const errorMessage = error.response?.data?.message || 
                        error.response?.data?.errors?.[0] || 
                        error.message;
    
    return Promise.reject(new Error(errorMessage));
  }
);

export default api;
```

### 5. Frontend Service Layer
**User Service**: `src/services/userService.js`
```javascript
import api from './api';

const userService = {
  async getUsers(page = 0, size = 10) {
    const response = await api.get(`/users?page=${page}&size=${size}`);
    return response.data;
  },

  async getUserById(id) {
    const response = await api.get(`/users/${id}`);
    return response.data;
  },

  async createUser(userData) {
    const response = await api.post('/users', userData);
    return response.data;
  },

  async updateUser(id, userData) {
    const response = await api.put(`/users/${id}`, userData);
    return response.data;
  },

  async deleteUser(id) {
    await api.delete(`/users/${id}`);
  },
};

export default userService;
```

### 6. Frontend Data Fetching Hook
**Data Hook**: `src/hooks/useApiData.js`
```javascript
import { useState, useEffect } from 'react';

export function useApiData(serviceFunction, dependencies = []) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        const result = await serviceFunction();
        setData(result);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, dependencies);

  const refetch = async () => {
    try {
      setLoading(true);
      setError(null);
      const result = await serviceFunction();
      setData(result);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return { data, loading, error, refetch };
}
```

### 7. Frontend Component Integration
**User List Component**: `src/components/users/UserList.js`
```javascript
import { useState } from 'react';
import { useApiData } from '../../hooks/useApiData';
import userService from '../../services/userService';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Button,
  Grid,
  Alert,
  Pagination,
} from '@mui/material';
import Loading from '../common/Loading';

export default function UserList() {
  const [page, setPage] = useState(0);
  const { data, loading, error, refetch } = useApiData(
    () => userService.getUsers(page, 10),
    [page]
  );

  const handleDelete = async (userId) => {
    try {
      await userService.deleteUser(userId);
      refetch(); // Refresh the list
    } catch (err) {
      console.error('Delete failed:', err);
    }
  };

  if (loading) return <Loading />;
  if (error) return <Alert severity="error">{error}</Alert>;

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Users
      </Typography>
      
      <Grid container spacing={2}>
        {data?.content?.map((user) => (
          <Grid item xs={12} md={6} key={user.id}>
            <Card>
              <CardContent>
                <Typography variant="h6">{user.name}</Typography>
                <Typography color="textSecondary">{user.email}</Typography>
                <Box mt={2}>
                  <Button
                    variant="outlined"
                    color="error"
                    onClick={() => handleDelete(user.id)}
                  >
                    Delete
                  </Button>
                </Box>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      {data && (
        <Box display="flex" justifyContent="center" mt={3}>
          <Pagination
            count={data.totalPages}
            page={page + 1}
            onChange={(event, value) => setPage(value - 1)}
          />
        </Box>
      )}
    </Box>
  );
}
```

### 8. Error Handling Pattern
**Global Error Handler**: `src/main/kotlin/exception/GlobalExceptionHandler.kt`
```kotlin
@RestControllerAdvice
class GlobalExceptionHandler {
    
    @ExceptionHandler(ValidationException::class)
    fun handleValidation(e: ValidationException): ResponseEntity<ApiResponse<Nothing>> {
        return ResponseEntity.badRequest().body(
            ApiResponse(
                success = false,
                message = "Validation failed",
                errors = e.errors
            )
        )
    }
    
    @ExceptionHandler(EntityNotFoundException::class)
    fun handleNotFound(e: EntityNotFoundException): ResponseEntity<ApiResponse<Nothing>> {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
            ApiResponse(
                success = false,
                message = e.message
            )
        )
    }
    
    @ExceptionHandler(Exception::class)
    fun handleGeneral(e: Exception): ResponseEntity<ApiResponse<Nothing>> {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
            ApiResponse(
                success = false,
                message = "An unexpected error occurred"
            )
        )
    }
}
```

### 9. Environment Configuration
**Backend Properties**: `application.yml`
```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/myapp
    username: ${DB_USERNAME:postgres}
    password: ${DB_PASSWORD:password}
  
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false

cors:
  allowed-origins: ${CORS_ORIGINS:http://localhost:3000}

jwt:
  secret: ${JWT_SECRET:your-secret-key}
  expiration: 3600000
```

**Frontend Environment**: `.env.local`
```bash
NEXT_PUBLIC_API_URL=http://localhost:8080/api
NEXT_PUBLIC_APP_NAME=My Application
```

### 10. Development Proxy Configuration
**Next.js Config**: `next.config.js`
```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  async rewrites() {
    return process.env.NODE_ENV === 'development'
      ? [
          {
            source: '/api/:path*',
            destination: 'http://localhost:8080/api/:path*',
          },
        ]
      : [];
  },
};

module.exports = nextConfig;
```

## CLAUDE_CODE_COMMANDS

### Development Setup
```bash
# Start backend (Spring Boot)
cd backend
./gradlew bootRun

# Start frontend (Next.js)
cd frontend
npm run dev

# Both accessible at:
# Frontend: http://localhost:3000
# Backend: http://localhost:8080
```

### Integration Testing
```bash
# Test API connectivity
curl -X GET http://localhost:8080/api/users \
  -H "Authorization: Bearer <token>"

# Test CORS
curl -X OPTIONS http://localhost:8080/api/users \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET"
```

### Production Build
```bash
# Backend JAR
./gradlew bootJar

# Frontend static build
npm run build
npm start
```

## VALIDATION_CHECKLIST
- [ ] CORS properly configured for all environments
- [ ] API responses follow consistent DTO pattern
- [ ] Frontend API client handles authentication automatically
- [ ] Error handling works end-to-end
- [ ] Pagination and data fetching implemented
- [ ] Environment configuration for dev/prod
- [ ] JWT authentication integrated
- [ ] Loading states and error messages displayed
- [ ] API service layer properly abstracts backend calls
- [ ] Production deployment configuration ready