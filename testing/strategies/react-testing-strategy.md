# React Testing Strategy - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: medium
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Dependencies
```json
{
  "devDependencies": {
    "@testing-library/react": "^13.4.0",
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/user-event": "^14.4.3",
    "jest": "^29.7.0",
    "jest-environment-jsdom": "^29.7.0",
    "msw": "^1.3.2",
    "cypress": "^13.6.0",
    "@cypress/react": "^7.0.3",
    "@storybook/react": "^7.6.3",
    "eslint-plugin-testing-library": "^6.2.0",
    "eslint-plugin-jest-dom": "^5.1.0"
  }
}
```

### Jest Configuration
```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.js'],
  moduleNameMapping: {
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
    '\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2)$': '<rootDir>/__mocks__/fileMock.js'
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx}',
    '!src/index.js',
    '!src/serviceWorker.js',
    '!src/setupTests.js'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  },
  testMatch: [
    '<rootDir>/src/**/__tests__/**/*.{js,jsx}',
    '<rootDir>/src/**/*.{test,spec}.{js,jsx}'
  ]
};
```

## IMPLEMENTATION STRATEGY

### Component Unit Testing
```javascript
// src/components/UserCard.test.js
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { UserCard } from './UserCard';

// Mock external dependencies
jest.mock('../services/userService', () => ({
  updateUser: jest.fn(),
  deleteUser: jest.fn()
}));

describe('UserCard Component', () => {
  const mockUser = {
    id: 1,
    firstName: 'John',
    lastName: 'Doe',
    email: 'john.doe@example.com',
    isActive: true
  };

  const defaultProps = {
    user: mockUser,
    onEdit: jest.fn(),
    onDelete: jest.fn()
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders user information correctly', () => {
    render(<UserCard {...defaultProps} />);
    
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john.doe@example.com')).toBeInTheDocument();
    expect(screen.getByTestId('user-status')).toHaveTextContent('Active');
  });

  test('displays inactive status for inactive users', () => {
    const inactiveUser = { ...mockUser, isActive: false };
    render(<UserCard {...defaultProps} user={inactiveUser} />);
    
    expect(screen.getByTestId('user-status')).toHaveTextContent('Inactive');
  });

  test('calls onEdit when edit button is clicked', async () => {
    const user = userEvent.setup();
    render(<UserCard {...defaultProps} />);
    
    const editButton = screen.getByRole('button', { name: /edit/i });
    await user.click(editButton);
    
    expect(defaultProps.onEdit).toHaveBeenCalledWith(mockUser);
    expect(defaultProps.onEdit).toHaveBeenCalledTimes(1);
  });

  test('calls onDelete when delete button is clicked', async () => {
    const user = userEvent.setup();
    render(<UserCard {...defaultProps} />);
    
    const deleteButton = screen.getByRole('button', { name: /delete/i });
    await user.click(deleteButton);
    
    expect(defaultProps.onDelete).toHaveBeenCalledWith(mockUser.id);
    expect(defaultProps.onDelete).toHaveBeenCalledTimes(1);
  });

  test('shows loading state during async operations', async () => {
    const user = userEvent.setup();
    
    // Mock a delayed operation
    const mockOnEdit = jest.fn(() => new Promise(resolve => setTimeout(resolve, 100)));
    
    render(<UserCard {...defaultProps} onEdit={mockOnEdit} />);
    
    const editButton = screen.getByRole('button', { name: /edit/i });
    await user.click(editButton);
    
    expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
    
    await waitFor(() => {
      expect(screen.queryByTestId('loading-spinner')).not.toBeInTheDocument();
    });
  });

  test('handles keyboard navigation properly', async () => {
    const user = userEvent.setup();
    render(<UserCard {...defaultProps} />);
    
    const editButton = screen.getByRole('button', { name: /edit/i });
    const deleteButton = screen.getByRole('button', { name: /delete/i });
    
    // Tab to edit button
    await user.tab();
    expect(editButton).toHaveFocus();
    
    // Tab to delete button
    await user.tab();
    expect(deleteButton).toHaveFocus();
    
    // Enter should trigger click
    await user.keyboard('{Enter}');
    expect(defaultProps.onDelete).toHaveBeenCalledWith(mockUser.id);
  });
});
```

### Form Testing
```javascript
// src/components/UserForm.test.js
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserForm } from './UserForm';
import { userService } from '../services/userService';

jest.mock('../services/userService');

describe('UserForm Component', () => {
  const mockOnSubmit = jest.fn();
  const mockOnCancel = jest.fn();

  const defaultProps = {
    onSubmit: mockOnSubmit,
    onCancel: mockOnCancel
  };

  beforeEach(() => {
    jest.clearAllMocks();
    userService.createUser.mockResolvedValue({ id: 1, firstName: 'John' });
  });

  test('submits form with valid data', async () => {
    const user = userEvent.setup();
    render(<UserForm {...defaultProps} />);
    
    // Fill form fields
    await user.type(screen.getByLabelText(/first name/i), 'John');
    await user.type(screen.getByLabelText(/last name/i), 'Doe');
    await user.type(screen.getByLabelText(/email/i), 'john.doe@example.com');
    
    // Submit form
    await user.click(screen.getByRole('button', { name: /save/i }));
    
    await waitFor(() => {
      expect(userService.createUser).toHaveBeenCalledWith({
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com'
      });
    });
    
    expect(mockOnSubmit).toHaveBeenCalledWith({
      id: 1,
      firstName: 'John'
    });
  });

  test('shows validation errors for invalid input', async () => {
    const user = userEvent.setup();
    render(<UserForm {...defaultProps} />);
    
    // Try to submit empty form
    await user.click(screen.getByRole('button', { name: /save/i }));
    
    expect(screen.getByText(/first name is required/i)).toBeInTheDocument();
    expect(screen.getByText(/last name is required/i)).toBeInTheDocument();
    expect(screen.getByText(/email is required/i)).toBeInTheDocument();
    
    // Form should not be submitted
    expect(userService.createUser).not.toHaveBeenCalled();
    expect(mockOnSubmit).not.toHaveBeenCalled();
  });

  test('validates email format', async () => {
    const user = userEvent.setup();
    render(<UserForm {...defaultProps} />);
    
    await user.type(screen.getByLabelText(/first name/i), 'John');
    await user.type(screen.getByLabelText(/last name/i), 'Doe');
    await user.type(screen.getByLabelText(/email/i), 'invalid-email');
    
    await user.click(screen.getByRole('button', { name: /save/i }));
    
    expect(screen.getByText(/please enter a valid email/i)).toBeInTheDocument();
    expect(userService.createUser).not.toHaveBeenCalled();
  });

  test('handles server errors gracefully', async () => {
    const user = userEvent.setup();
    userService.createUser.mockRejectedValue(new Error('Server error'));
    
    render(<UserForm {...defaultProps} />);
    
    await user.type(screen.getByLabelText(/first name/i), 'John');
    await user.type(screen.getByLabelText(/last name/i), 'Doe');
    await user.type(screen.getByLabelText(/email/i), 'john.doe@example.com');
    
    await user.click(screen.getByRole('button', { name: /save/i }));
    
    await waitFor(() => {
      expect(screen.getByText(/an error occurred while saving/i)).toBeInTheDocument();
    });
    
    expect(mockOnSubmit).not.toHaveBeenCalled();
  });

  test('resets form when cancel is clicked', async () => {
    const user = userEvent.setup();
    render(<UserForm {...defaultProps} />);
    
    // Fill form
    await user.type(screen.getByLabelText(/first name/i), 'John');
    await user.type(screen.getByLabelText(/last name/i), 'Doe');
    
    // Click cancel
    await user.click(screen.getByRole('button', { name: /cancel/i }));
    
    expect(mockOnCancel).toHaveBeenCalled();
    expect(screen.getByLabelText(/first name/i)).toHaveValue('');
    expect(screen.getByLabelText(/last name/i)).toHaveValue('');
  });
});
```

### Hook Testing
```javascript
// src/hooks/useUsers.test.js
import { renderHook, act, waitFor } from '@testing-library/react';
import { useUsers } from './useUsers';
import { userService } from '../services/userService';

jest.mock('../services/userService');

describe('useUsers Hook', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('fetches users on mount', async () => {
    const mockUsers = [
      { id: 1, firstName: 'John', lastName: 'Doe' },
      { id: 2, firstName: 'Jane', lastName: 'Smith' }
    ];
    
    userService.getUsers.mockResolvedValue(mockUsers);
    
    const { result } = renderHook(() => useUsers());
    
    expect(result.current.loading).toBe(true);
    expect(result.current.users).toEqual([]);
    
    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });
    
    expect(result.current.users).toEqual(mockUsers);
    expect(result.current.error).toBe(null);
  });

  test('handles fetch error', async () => {
    const errorMessage = 'Failed to fetch users';
    userService.getUsers.mockRejectedValue(new Error(errorMessage));
    
    const { result } = renderHook(() => useUsers());
    
    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });
    
    expect(result.current.users).toEqual([]);
    expect(result.current.error).toBe(errorMessage);
  });

  test('creates user successfully', async () => {
    const existingUsers = [{ id: 1, firstName: 'John', lastName: 'Doe' }];
    const newUser = { id: 2, firstName: 'Jane', lastName: 'Smith' };
    
    userService.getUsers.mockResolvedValue(existingUsers);
    userService.createUser.mockResolvedValue(newUser);
    
    const { result } = renderHook(() => useUsers());
    
    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });
    
    await act(async () => {
      await result.current.createUser({
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane@example.com'
      });
    });
    
    expect(result.current.users).toEqual([...existingUsers, newUser]);
  });

  test('deletes user successfully', async () => {
    const mockUsers = [
      { id: 1, firstName: 'John', lastName: 'Doe' },
      { id: 2, firstName: 'Jane', lastName: 'Smith' }
    ];
    
    userService.getUsers.mockResolvedValue(mockUsers);
    userService.deleteUser.mockResolvedValue();
    
    const { result } = renderHook(() => useUsers());
    
    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });
    
    await act(async () => {
      await result.current.deleteUser(1);
    });
    
    expect(result.current.users).toEqual([
      { id: 2, firstName: 'Jane', lastName: 'Smith' }
    ]);
  });
});
```

### API Integration Testing with MSW
```javascript
// src/mocks/handlers.js
import { rest } from 'msw';

export const handlers = [
  rest.get('/api/users', (req, res, ctx) => {
    return res(
      ctx.json([
        { id: 1, firstName: 'John', lastName: 'Doe', email: 'john@example.com' },
        { id: 2, firstName: 'Jane', lastName: 'Smith', email: 'jane@example.com' }
      ])
    );
  }),

  rest.post('/api/users', (req, res, ctx) => {
    const { firstName, lastName, email } = req.body;
    return res(
      ctx.status(201),
      ctx.json({
        id: 3,
        firstName,
        lastName,
        email,
        isActive: true
      })
    );
  }),

  rest.put('/api/users/:id', (req, res, ctx) => {
    const { id } = req.params;
    const updatedUser = req.body;
    return res(
      ctx.json({
        id: parseInt(id),
        ...updatedUser
      })
    );
  }),

  rest.delete('/api/users/:id', (req, res, ctx) => {
    return res(ctx.status(204));
  }),

  // Error scenarios
  rest.get('/api/users/error', (req, res, ctx) => {
    return res(
      ctx.status(500),
      ctx.json({ message: 'Internal server error' })
    );
  })
];

// src/mocks/server.js
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);

// src/setupTests.js
import '@testing-library/jest-dom';
import { server } from './mocks/server';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Integration Testing
```javascript
// src/components/UserList.integration.test.js
import React from 'react';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserList } from './UserList';
import { server } from '../mocks/server';
import { rest } from 'msw';

describe('UserList Integration', () => {
  test('displays users from API', async () => {
    render(<UserList />);
    
    expect(screen.getByText(/loading/i)).toBeInTheDocument();
    
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('Jane Smith')).toBeInTheDocument();
    });
    
    expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
  });

  test('creates new user and updates list', async () => {
    const user = userEvent.setup();
    render(<UserList />);
    
    // Wait for initial load
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });
    
    // Open create form
    await user.click(screen.getByRole('button', { name: /add user/i }));
    
    // Fill form
    await user.type(screen.getByLabelText(/first name/i), 'Bob');
    await user.type(screen.getByLabelText(/last name/i), 'Johnson');
    await user.type(screen.getByLabelText(/email/i), 'bob@example.com');
    
    // Submit form
    await user.click(screen.getByRole('button', { name: /save/i }));
    
    // Verify new user appears in list
    await waitFor(() => {
      expect(screen.getByText('Bob Johnson')).toBeInTheDocument();
    });
  });

  test('handles API errors gracefully', async () => {
    // Override handler to return error
    server.use(
      rest.get('/api/users', (req, res, ctx) => {
        return res(
          ctx.status(500),
          ctx.json({ message: 'Server error' })
        );
      })
    );
    
    render(<UserList />);
    
    await waitFor(() => {
      expect(screen.getByText(/error loading users/i)).toBeInTheDocument();
    });
    
    // Verify retry functionality
    const retryButton = screen.getByRole('button', { name: /retry/i });
    expect(retryButton).toBeInTheDocument();
  });

  test('filters users by search term', async () => {
    const user = userEvent.setup();
    render(<UserList />);
    
    // Wait for users to load
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('Jane Smith')).toBeInTheDocument();
    });
    
    // Search for "John"
    const searchInput = screen.getByLabelText(/search/i);
    await user.type(searchInput, 'John');
    
    // Verify only John is visible
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.queryByText('Jane Smith')).not.toBeInTheDocument();
  });
});
```

### Cypress E2E Testing
```javascript
// cypress/e2e/user-management.cy.js
describe('User Management E2E', () => {
  beforeEach(() => {
    cy.intercept('GET', '/api/users', { fixture: 'users.json' }).as('getUsers');
    cy.visit('/users');
  });

  it('displays user list', () => {
    cy.wait('@getUsers');
    cy.get('[data-testid="user-card"]').should('have.length', 2);
    cy.contains('John Doe').should('be.visible');
    cy.contains('Jane Smith').should('be.visible');
  });

  it('creates new user', () => {
    cy.intercept('POST', '/api/users', {
      statusCode: 201,
      body: { id: 3, firstName: 'Bob', lastName: 'Johnson', email: 'bob@example.com' }
    }).as('createUser');

    cy.get('[data-testid="add-user-button"]').click();
    
    cy.get('[data-testid="first-name-input"]').type('Bob');
    cy.get('[data-testid="last-name-input"]').type('Johnson');
    cy.get('[data-testid="email-input"]').type('bob@example.com');
    
    cy.get('[data-testid="save-button"]').click();
    
    cy.wait('@createUser');
    cy.contains('Bob Johnson').should('be.visible');
  });

  it('validates form inputs', () => {
    cy.get('[data-testid="add-user-button"]').click();
    cy.get('[data-testid="save-button"]').click();
    
    cy.contains('First name is required').should('be.visible');
    cy.contains('Last name is required').should('be.visible');
    cy.contains('Email is required').should('be.visible');
  });

  it('handles network errors', () => {
    cy.intercept('GET', '/api/users', { statusCode: 500 }).as('getUsersError');
    cy.visit('/users');
    
    cy.wait('@getUsersError');
    cy.contains('Error loading users').should('be.visible');
    cy.get('[data-testid="retry-button"]').should('be.visible');
  });
});

// cypress/fixtures/users.json
[
  { "id": 1, "firstName": "John", "lastName": "Doe", "email": "john@example.com" },
  { "id": 2, "firstName": "Jane", "lastName": "Smith", "email": "jane@example.com" }
]
```

### Accessibility Testing
```javascript
// src/components/UserCard.a11y.test.js
import React from 'react';
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';
import { UserCard } from './UserCard';

expect.extend(toHaveNoViolations);

describe('UserCard Accessibility', () => {
  const mockUser = {
    id: 1,
    firstName: 'John',
    lastName: 'Doe',
    email: 'john.doe@example.com',
    isActive: true
  };

  test('should not have accessibility violations', async () => {
    const { container } = render(
      <UserCard 
        user={mockUser}
        onEdit={jest.fn()}
        onDelete={jest.fn()}
      />
    );
    
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  test('has proper ARIA labels', () => {
    const { getByRole } = render(
      <UserCard 
        user={mockUser}
        onEdit={jest.fn()}
        onDelete={jest.fn()}
      />
    );
    
    expect(getByRole('button', { name: /edit john doe/i })).toBeInTheDocument();
    expect(getByRole('button', { name: /delete john doe/i })).toBeInTheDocument();
  });
});
```

## CLAUDE_CODE_COMMANDS

```bash
# Run all tests
npm test

# Run tests in watch mode
npm test -- --watch

# Run tests with coverage
npm test -- --coverage

# Run specific test file
npm test UserCard.test.js

# Run integration tests
npm test -- --testPathPattern=integration

# Run Cypress E2E tests
npx cypress run

# Open Cypress test runner
npx cypress open

# Run accessibility tests
npm test -- --testNamePattern="accessibility"
```

## VALIDATION_CHECKLIST
- [ ] Component unit tests cover all props and states
- [ ] Form validation logic thoroughly tested
- [ ] Custom hooks tested in isolation
- [ ] API integration tested with MSW
- [ ] Error handling scenarios covered
- [ ] Accessibility compliance verified
- [ ] E2E user flows tested with Cypress
- [ ] Loading states and async operations tested
- [ ] Keyboard navigation and focus management tested
- [ ] Code coverage above 80% threshold