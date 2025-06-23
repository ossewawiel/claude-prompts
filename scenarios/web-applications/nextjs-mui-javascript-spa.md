# Next.js MUI JavaScript SPA - Claude Code Instructions

## CONTEXT
- **Project Type**: scenario
- **Complexity**: medium
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Technology Stack
- **Frontend**: Next.js 14+ with App Router
- **UI Library**: Material-UI (MUI) v5+
- **Language**: JavaScript (ES6+)
- **Styling**: MUI styled components + CSS modules
- **State Management**: React Context API or Zustand
- **HTTP Client**: Axios or fetch API
- **Build Tool**: Next.js built-in Webpack

### Project Structure
```
src/
├── app/                    # Next.js App Router
│   ├── layout.js          # Root layout with MUI theme
│   ├── page.js            # Home page
│   ├── globals.css        # Global styles
│   └── [feature]/         # Feature-based routing
├── components/            # Reusable UI components
│   ├── common/           # Generic components
│   └── layout/           # Layout components
├── contexts/             # React Context providers
├── hooks/               # Custom React hooks
├── lib/                 # Utility libraries
├── services/            # API service functions
└── styles/              # Additional styling
```

## IMPLEMENTATION STRATEGY

### 1. Project Setup
```bash
# Create Next.js project
npx create-next-app@latest project-name --js --tailwind --eslint --app --src-dir

# Install MUI dependencies
npm install @mui/material @emotion/react @emotion/styled
npm install @mui/icons-material @mui/x-date-pickers

# Install additional dependencies
npm install axios zustand
```

### 2. MUI Theme Configuration
**File**: `src/app/layout.js`
```javascript
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';

const theme = createTheme({
  palette: {
    primary: { main: '#1976d2' },
    secondary: { main: '#dc004e' },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
  },
});

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <ThemeProvider theme={theme}>
          <CssBaseline />
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
```

### 3. Component Structure
**Base Layout Component**: `src/components/layout/AppLayout.js`
```javascript
import { AppBar, Toolbar, Typography, Container, Box } from '@mui/material';

export default function AppLayout({ children }) {
  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            App Name
          </Typography>
        </Toolbar>
      </AppBar>
      <Container maxWidth="lg">
        <Box sx={{ mt: 4, mb: 4 }}>
          {children}
        </Box>
      </Container>
    </>
  );
}
```

### 4. State Management
**Context Setup**: `src/contexts/AppContext.js`
```javascript
import { createContext, useContext, useReducer } from 'react';

const AppContext = createContext();

const initialState = {
  user: null,
  loading: false,
  error: null,
};

function appReducer(state, action) {
  switch (action.type) {
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    case 'SET_ERROR':
      return { ...state, error: action.payload };
    case 'SET_USER':
      return { ...state, user: action.payload };
    default:
      return state;
  }
}

export function AppProvider({ children }) {
  const [state, dispatch] = useReducer(appReducer, initialState);
  
  return (
    <AppContext.Provider value={{ state, dispatch }}>
      {children}
    </AppContext.Provider>
  );
}

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within AppProvider');
  }
  return context;
};
```

### 5. API Service Layer
**Base Service**: `src/services/api.js`
```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080/api',
  timeout: 10000,
});

// Request interceptor
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

// Response interceptor
api.interceptors.response.use(
  (response) => response.data,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('auth_token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
```

### 6. Custom Hooks
**Data Fetching Hook**: `src/hooks/useApi.js`
```javascript
import { useState, useEffect } from 'react';
import api from '../services/api';

export function useApi(url, options = {}) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await api.get(url, options);
        setData(response);
      } catch (err) {
        setError(err);
      } finally {
        setLoading(false);
      }
    };

    if (url) fetchData();
  }, [url]);

  return { data, loading, error };
}
```

### 7. Common Components
**Loading Component**: `src/components/common/Loading.js`
```javascript
import { CircularProgress, Box } from '@mui/material';

export default function Loading() {
  return (
    <Box display="flex" justifyContent="center" p={3}>
      <CircularProgress />
    </Box>
  );
}
```

**Error Component**: `src/components/common/ErrorMessage.js`
```javascript
import { Alert } from '@mui/material';

export default function ErrorMessage({ message }) {
  return (
    <Alert severity="error" sx={{ mt: 2 }}>
      {message || 'An error occurred'}
    </Alert>
  );
}
```

## CLAUDE_CODE_COMMANDS

### Development Setup
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

### Code Quality
```bash
# Lint JavaScript
npm run lint

# Fix linting issues
npm run lint -- --fix

# Type checking (if using PropTypes)
npm run build
```

### Testing Commands
```bash
# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
```

## VALIDATION_CHECKLIST
- [ ] Next.js App Router structure implemented
- [ ] MUI theme configuration working
- [ ] Component library structure established
- [ ] State management pattern implemented
- [ ] API service layer configured
- [ ] Custom hooks for common operations
- [ ] Error handling and loading states
- [ ] Responsive design with MUI breakpoints
- [ ] ESLint configuration following JavaScript standards
- [ ] Production build optimization configured