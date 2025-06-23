# React JavaScript Coding Standards - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: simple
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Code Formatting
- **Formatter**: Prettier 3.0+
- **Linter**: ESLint with React plugin
- **Line Length**: 120 characters
- **Indentation**: 2 spaces for JSX, 4 spaces for JS
- **Quote Style**: Single quotes for JS, double quotes for JSX attributes

### File Organization
```javascript
// UserService.js - Utility/Service files
import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080/api';

export const userService = {
    async fetchUser(id) {
        const response = await axios.get(`${API_BASE_URL}/users/${id}`);
        return response.data;
    },
    
    async createUser(userData) {
        const response = await axios.post(`${API_BASE_URL}/users`, userData);
        return response.data;
    }
};
```

```jsx
// UserCard.jsx - React Components
import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { userService } from '../services/UserService';

const UserCard = ({ userId, onUserSelect }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const loadUser = async () => {
            try {
                setLoading(true);
                const userData = await userService.fetchUser(userId);
                setUser(userData);
            } catch (err) {
                setError(err.message);
            } finally {
                setLoading(false);
            }
        };

        loadUser();
    }, [userId]);

    const handleClick = () => {
        onUserSelect(user);
    };

    if (loading) return <div className="loading">Loading...</div>;
    if (error) return <div className="error">Error: {error}</div>;
    if (!user) return null;

    return (
        <div className="user-card" onClick={handleClick}>
            <h3>{user.name}</h3>
            <p>{user.email}</p>
        </div>
    );
};

UserCard.propTypes = {
    userId: PropTypes.number.isRequired,
    onUserSelect: PropTypes.func.isRequired
};

export default UserCard;
```

## IMPLEMENTATION STRATEGY

### Naming Conventions
- **Components**: PascalCase (`UserCard`, `NavigationMenu`)
- **Files**: PascalCase for components (`UserCard.jsx`), camelCase for utilities (`userService.js`)
- **Variables/Functions**: camelCase (`userName`, `handleClick`)
- **Constants**: SCREAMING_SNAKE_CASE (`API_BASE_URL`)
- **CSS Classes**: kebab-case (`user-card`, `navigation-menu`)

### Component Structure
```jsx
// Functional Components (preferred)
const UserList = ({ users, onUserSelect }) => {
    const [selectedUser, setSelectedUser] = useState(null);

    const handleUserClick = (user) => {
        setSelectedUser(user);
        onUserSelect(user);
    };

    return (
        <div className="user-list">
            {users.map(user => (
                <UserCard
                    key={user.id}
                    user={user}
                    isSelected={selectedUser?.id === user.id}
                    onClick={() => handleUserClick(user)}
                />
            ))}
        </div>
    );
};

// Custom Hooks
const useUsers = () => {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        userService.fetchUsers()
            .then(setUsers)
            .catch(console.error)
            .finally(() => setLoading(false));
    }, []);

    return { users, loading };
};
```

### State Management
```jsx
// Local State with useState
const [formData, setFormData] = useState({
    name: '',
    email: '',
    age: 0
});

// Handle form updates
const handleInputChange = (event) => {
    const { name, value } = event.target;
    setFormData(prev => ({
        ...prev,
        [name]: value
    }));
};

// Context for global state
const UserContext = createContext();

export const UserProvider = ({ children }) => {
    const [currentUser, setCurrentUser] = useState(null);
    
    const login = async (credentials) => {
        const user = await userService.login(credentials);
        setCurrentUser(user);
    };
    
    return (
        <UserContext.Provider value={{ currentUser, login }}>
            {children}
        </UserContext.Provider>
    );
};
```

### Event Handling
```jsx
// Inline handlers for simple operations
<button onClick={() => setCount(count + 1)}>
    Increment
</button>

// Separate functions for complex logic
const handleFormSubmit = async (event) => {
    event.preventDefault();
    
    try {
        await userService.createUser(formData);
        setFormData({ name: '', email: '', age: 0 });
        onSuccess('User created successfully');
    } catch (error) {
        onError(error.message);
    }
};

<form onSubmit={handleFormSubmit}>
    {/* form fields */}
</form>
```

## CLAUDE_CODE_COMMANDS

```bash
# Install dependencies
npm install prettier eslint eslint-plugin-react prop-types

# Format code
npx prettier --write "src/**/*.{js,jsx}"

# Lint code
npx eslint "src/**/*.{js,jsx}" --fix

# Run development server
npm start
```

## VALIDATION_CHECKLIST
- [ ] All components use PascalCase naming
- [ ] All variables use camelCase naming
- [ ] PropTypes defined for all components
- [ ] No console.log statements in production code
- [ ] useState and useEffect used correctly
- [ ] Event handlers properly named (handle* or on*)
- [ ] ESLint passes without errors
- [ ] Prettier formatting applied