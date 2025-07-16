# Entity Validation & Security Analysis

## CRITICAL Issues
- Sensitive fields (password, SSN) not excluded from toString
- No @NotNull validation on required fields
- Missing @Size validation on String fields
- Passwords stored in plain text without encoding

## HIGH Priority Issues
- @Email validation missing on email fields
- No @Valid on nested objects
- Missing @Pattern validation for structured data
- Sensitive data in equals/hashCode methods

## MEDIUM Priority Issues
- No @Min/@Max validation on numeric fields
- Missing @Past/@Future validation on date fields
- No custom validation annotations for business rules
- @JsonIgnore missing on sensitive fields

## LOW Priority Issues
- No @Digits validation on monetary fields
- Missing @DecimalMin/@DecimalMax on decimal fields
- No @AssertTrue/@AssertFalse for boolean validation
- Missing validation groups for different scenarios

## TODO Templates


### Missing @NotNull validation
```java
// TODO: [CRITICAL] Add @NotNull validation on required fields
// Fix: @NotNull(message = "Field is required")
@NotNull(message = "Email is required")
@Column(nullable = false)
private String email;
```

### Missing @Size validation
```java
// TODO: [CRITICAL] Add @Size validation on String fields
// Fix: @Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
@Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
@Column(length = 50)
private String firstName;
```

### Password not secured
```java
// TODO: [CRITICAL] Exclude password from toString and equals
// Fix: @ToString.Exclude and @EqualsAndHashCode.Exclude
@ToString.Exclude
@EqualsAndHashCode.Exclude
@JsonIgnore
private String password;
```

### Missing @Email validation
```java
// TODO: [HIGH] Add @Email validation
// Fix: @Email(message = "Invalid email format")
@Email(message = "Invalid email format")
@Column(unique = true)
private String email;
```

### No @Valid on nested objects
```java
// TODO: [HIGH] Add @Valid for nested object validation
// Fix: @Valid validates nested objects
@Valid
@Embedded
private Address address;
```

### Missing @Pattern validation
```java
// TODO: [HIGH] Add @Pattern validation for structured data
// Fix: @Pattern(regexp = "^[0-9]{3}-[0-9]{2}-[0-9]{4}$", message = "Invalid SSN format")
@Pattern(regexp = "^[0-9]{3}-[0-9]{2}-[0-9]{4}$", message = "Invalid SSN format")
@ToString.Exclude
@EqualsAndHashCode.Exclude
private String ssn;
```

### Sensitive data in equals/hashCode
```java
// TODO: [HIGH] Exclude sensitive data from equals/hashCode
// Fix: @EqualsAndHashCode.Exclude
@EqualsAndHashCode.Exclude
@JsonIgnore
private String password;
```

### Missing @Min/@Max validation
```java
// TODO: [MEDIUM] Add @Min/@Max validation on numeric fields
// Fix: @Min(value = 0, message = "Age cannot be negative")
@Min(value = 0, message = "Age cannot be negative")
@Max(value = 150, message = "Age cannot exceed 150")
private Integer age;
```

### Missing @Past/@Future validation
```java
// TODO: [MEDIUM] Add @Past/@Future validation on date fields
// Fix: @Past(message = "Birth date must be in the past")
@Past(message = "Birth date must be in the past")
private LocalDate birthDate;
```

### No custom validation
```java
// TODO: [MEDIUM] Add custom validation for business rules
// Fix: Create custom validation annotation
@ValidUserStatus
private UserStatus status;
```

### Missing @JsonIgnore
```java
// TODO: [MEDIUM] Add @JsonIgnore on sensitive fields
// Fix: @JsonIgnore prevents JSON serialization
@JsonIgnore
@ToString.Exclude
private String password;
```

### Missing @Digits validation
```java
// TODO: [LOW] Add @Digits validation on monetary fields
// Fix: @Digits(integer = 10, fraction = 2, message = "Invalid amount format")
@Digits(integer = 10, fraction = 2, message = "Invalid amount format")
private BigDecimal amount;
```

### Missing @DecimalMin/@DecimalMax
```java
// TODO: [LOW] Add @DecimalMin/@DecimalMax validation
// Fix: @DecimalMin(value = "0.0", message = "Price cannot be negative")
@DecimalMin(value = "0.0", message = "Price cannot be negative")
@DecimalMax(value = "99999.99", message = "Price too high")
private BigDecimal price;
```

### Missing @AssertTrue/@AssertFalse
```java
// TODO: [LOW] Add @AssertTrue/@AssertFalse for boolean validation
// Fix: @AssertTrue(message = "Terms must be accepted")
@AssertTrue(message = "Terms must be accepted")
private boolean termsAccepted;
```

### Missing validation groups
```java
// TODO: [LOW] Add validation groups for different scenarios
// Fix: @NotNull(groups = {CreateGroup.class, UpdateGroup.class})
@NotNull(groups = {CreateGroup.class, UpdateGroup.class})
private String email;
```

## Security Best Practices

### Secure Entity Pattern
```java
@Entity
@Table(name = "users")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(exclude = {"password", "ssn", "creditCardNumber"})
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long id;
    
    @NotNull(message = "Email is required")
    @Email(message = "Invalid email format")
    @Size(max = 255, message = "Email too long")
    @Column(nullable = false, unique = true)
    private String email;
    
    @NotNull(message = "Password is required")
    @Size(min = 8, max = 255, message = "Password must be at least 8 characters")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @JsonIgnore
    private String password;
    
    @Pattern(regexp = "^[0-9]{3}-[0-9]{2}-[0-9]{4}$", message = "Invalid SSN format")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @JsonIgnore
    private String ssn;
    
    @Valid
    @Embedded
    private Address address;
    
    @Past(message = "Birth date must be in the past")
    private LocalDate birthDate;
    
    @Min(value = 0, message = "Age cannot be negative")
    @Max(value = 150, message = "Age cannot exceed 150")
    private Integer age;
}
```

### Validation Groups
```java
public interface CreateGroup {}
public interface UpdateGroup {}

@Entity
public class User {
    
    @NotNull(groups = CreateGroup.class)
    @Email(groups = {CreateGroup.class, UpdateGroup.class})
    private String email;
    
    @NotNull(groups = CreateGroup.class)
    @Size(min = 8, groups = {CreateGroup.class, UpdateGroup.class})
    private String password;
}
```

### Custom Validation
```java
@ValidUserStatus
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = UserStatusValidator.class)
public @interface ValidUserStatus {
    String message() default "Invalid user status";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
```

## Validation & Security Checklist
- [ ] @ToString excludes sensitive fields
- [ ] @EqualsAndHashCode excludes sensitive fields
- [ ] @JsonIgnore on sensitive fields
- [ ] @NotNull on required fields
- [ ] @Size on String fields with appropriate limits
- [ ] @Email on email fields
- [ ] @Pattern for structured data (SSN, phone, etc.)
- [ ] @Valid on nested objects
- [ ] @Min/@Max on numeric fields
- [ ] @Past/@Future on date fields
- [ ] @Digits on monetary fields
- [ ] @DecimalMin/@DecimalMax on decimal fields
- [ ] @AssertTrue/@AssertFalse for boolean validation
- [ ] Custom validation annotations for business rules
- [ ] Validation groups for different scenarios
- [ ] Column constraints match validation rules
- [ ] Passwords excluded from all output methods
- [ ] Sensitive data properly encrypted/hashed
- [ ] Input sanitization for XSS prevention
- [ ] SQL injection prevention through proper annotations