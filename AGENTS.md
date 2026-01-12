# AGENTS.md - Development Guidelines for Norakkan

This file contains essential information for AI coding agents working on this Rails 8 coffee e-commerce application.

## Project Overview

- **Framework**: Rails 8.0.4 with Ruby 3.4.6
- **Architecture**: Modern Rails MVC with Solid Stack (Solid Cache, Solid Queue, Solid Cable)
- **Frontend**: Hotwire (Turbo + Stimulus) with Importmap
- **Database**: SQLite3 (development), PostgreSQL (production)
- **Deployment**: Kamal with Docker
- **Domain**: Coffee e-commerce platform

## Essential Commands

### Development
```bash
bin/setup              # Initial setup (deps, DB, server)
bin/dev                # Start development server
bin/rails server       # Alternative server start
```

### Database
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/rails db:prepare   # Create, migrate, seed
```

### Testing - CRITICAL
```bash
# Run all tests
bin/rails test              # All tests except system
bin/rails test:all          # All tests including system
bin/rails test:system       # Only system tests

# Run specific test types
bin/rails test:models       # Model tests only
bin/rails test:controllers  # Controller tests only
bin/rails test:units        # Unit tests (models, helpers)

# RUN SINGLE TESTS - MOST IMPORTANT
bin/rails test test/models/product_test.rb:27
bin/rails test test/models/product_test.rb:10-20

# Test with DB reset
bin/rails test:db
```

### Code Quality
```bash
bin/rubocop                 # Check style
bin/rubocop -a              # Auto-fix style issues
bin/brakeman               # Security scan
bin/importmap audit        # JavaScript dependency security
```

### Assets
```bash
bin/importmap pin <package>    # Add JS package
bin/importmap unpin <package>  # Remove JS package
```

### Deployment
```bash
bin/kamal deploy           # Deploy to production
bin/kamal console          # Production Rails console
bin/kamal shell            # Production shell
```

## Code Style Guidelines

### Ruby/Rails
- Follow RuboCop Rails Omakase configuration
- Use standard Rails naming conventions
- Prefer `find_by` over `where(...).first`
- Use `!` methods for destructive operations when appropriate
- Keep controllers thin - business logic in models or service objects
- Use Rails 8 conventions (no more `application.js` in asset pipeline)

### JavaScript (Stimulus)
- Use Stimulus controllers for interactive behavior
- Avoid complex JavaScript - prefer Hotwire when possible
- Place controllers in `app/javascript/controllers/`
- Use data attributes for Stimulus targets and actions

### Testing
- Write tests for all new features
- Use descriptive test method names
- Test both happy path and edge cases
- Use fixtures for test data (already configured)
- Follow Rails testing patterns (Minitest)

### Database
- Use Rails migrations for schema changes
- Add proper indexes for foreign keys and frequently queried columns
- Use `null: false` and database constraints
- Consider `dependent: :destroy` for associations

## File Structure Conventions

### Models
- `app/models/` - ActiveRecord models
- Use concerns for shared model behavior
- Include validations and associations
- Add class methods for queries

### Controllers
- `app/controllers/` - Inherit from `ApplicationController`
- Keep actions focused (index, show, new, create, edit, update, destroy)
- Use strong parameters
- Handle success/error responses appropriately

### Views
- `app/views/` - ERB templates
- Use partials for repeated components
- Follow Turbo conventions for forms and links
- Use Stimulus for JavaScript interactions

### Tests
- `test/models/` - Model tests (inherit from `ActiveSupport::TestCase`)
- `test/controllers/` - Controller tests (inherit from `ActionDispatch::IntegrationTest`)
- `test/system/` - System tests with Capybara
- `test/fixtures/` - Test data fixtures

## Domain-Specific Guidelines

### Coffee E-commerce
- Products have variants (size, grind type)
- SKU generation system is implemented
- Cart functionality uses session-based storage
- Inventory management requires careful attention

### Key Models
- `User` - Authentication and profiles
- `Product` - Coffee products with metadata
- `Variant` - Product variations (size, grind)
- `Cart`/`CartItem` - Shopping cart functionality

## Security Considerations

- Always run `bin/brakeman` before committing
- Use Rails security features (CSRF protection, strong parameters)
- Never commit secrets or API keys
- Run `bin/importmap audit` when adding JavaScript packages

## Performance Guidelines

- Use Solid Queue for background jobs
- Implement proper database indexing
- Use Turbo for fast page updates
- Consider caching for frequently accessed data
- Use Thruster for HTTP asset compression in production

## Testing Workflow

1. Write failing test
2. Implement minimal code to pass test
3. Run `bin/rails test` to verify
4. Run `bin/rubocop` to check style
5. Run `bin/brakeman` for security
6. Commit changes

## CI/CD Pipeline

The project uses GitHub Actions with:
1. Security scans (Brakeman, Importmap audit)
2. Code style checks (RuboCop)
3. Full test suite execution
4. Artifact collection for failed system tests

Always ensure all checks pass before merging.

## Common Patterns

### Queries
```ruby
# Good
Product.includes(:variants).where(status: :active)

# Avoid N+1
Product.where(status: :active).each { |p| p.variants }
```

### Forms
```ruby
# Use form_with for Turbo compatibility
form_with(model: @product, data: { turbo_frame: "product_form" })
```

### Error Handling
- Use Rails validation errors
- Render proper error responses
- Handle exceptions gracefully in controllers

## Deployment Notes

- Uses Kamal for Docker-based deployment
- Solid Queue runs in Puma process
- SSL termination handled by proxy
- Environment variables managed securely

Remember: This is a production Rails 8 application - follow modern conventions and prioritize security, performance, and maintainability.
