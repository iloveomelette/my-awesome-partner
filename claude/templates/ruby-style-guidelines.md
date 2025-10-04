# Guidelines

## Ruby Style Guidelines

Follow the Ruby Style Guide (https://github.com/rubocop/ruby-style-guide) as the baseline. The custom rules below take precedence over the standard guide when there are conflicts.

### Code Style Rules
1. **Conditional Statements**
   - ALWAYS use `if !condition` instead of `unless condition`
   - Use `if condition` for positive conditions
   - Avoid `unless` with `else` clauses
   - Keep conditionals simple and readable

2. **Naming Conventions**
   - Use `snake_case` for methods, variables, and file names
   - Use `SCREAMING_SNAKE_CASE` for constants
   - Use `CamelCase` for classes and modules
   - Use meaningful, descriptive names

3. **Ruby Idioms**
   - Prefer `map` over `each` when transforming collections
   - Use `select` for filtering, `reject` for inverse filtering
   - Use `&:method_name` shorthand when appropriate
   - Leverage Ruby's built-in enumerable methods
   - Prefer string interpolation over concatenation

4. **Code Organization**
   - One class per file
   - Group related methods together
   - Keep methods short and focused (< 10 lines ideally)
   - Use private methods for internal logic

5. **Best Practices**
   - Avoid global variables
   - Use symbols for hash keys when possible
   - Prefer `&&`/`||` over `and`/`or` for boolean operations
   - Use parentheses for method calls with arguments
   - Avoid nested conditionals (max 2 levels deep)

## Rails-Specific Guidelines

Follow the Rails Style Guide (https://github.com/rubocop/rails-style-guide/blob/master/README.adoc) as the baseline. The custom rules below take precedence over the standard guide when there are conflicts.

### MVC Architecture
- Keep controllers thin - business logic belongs in models or service objects
- Views should only contain presentation logic
- Use concerns for shared behavior across models/controllers
- Avoid complex logic in views - use helpers or presenters

### ActiveRecord Best Practices
1. **N+1 Query Prevention**
   - ALWAYS use `preload` or `eager_load` for associations (DO NOT use `includes`)
   - Use `preload` when you don't need to reference the association in WHERE clause
   - Use `eager_load` when you need to reference the association in WHERE clause (LEFT OUTER JOIN)
   - Use `bullet` gem in development to detect N+1 queries
   - Example: `User.preload(:posts).where(active: true)` or `User.eager_load(:posts).where(posts: { published: true })`

2. **Query Optimization**
   - Use `select` to limit columns when fetching large datasets
   - Prefer `find_each` or `in_batches` for large record sets
   - Use database indexes for frequently queried columns
   - Avoid loading records when only counting: use `count` not `size` on queries

3. **Scopes and Queries**
   - Use scopes for reusable query logic
   - Chain scopes for complex queries
   - Prefer `where.not` over `where("column != ?", value)`

### Strong Parameters (Rails Version-Specific)

**Rails 7 and earlier:**
```ruby
# Define private permit method in controller
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    # ...
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :role)
  end
end
```

**Rails 8:**
```ruby
# Use `params.expect` (new pattern)
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    # ...
  end

  private

  def user_params
    params.expect(user: [:name, :email, :role])
  end
end

# For nested attributes
def user_params
  params.expect(user: [:name, :email, { address: [:street, :city] }])
end
```

**Key Differences:**
- Rails 8 `params.expect` raises `ActionController::ParameterMissing` if required key is missing
- Rails 7 `params.require().permit()` has similar behavior but different syntax
- Rails 8 syntax is more concise and expressive
- Both prevent mass assignment vulnerabilities

### Validations and Callbacks
- Place validations in models, not controllers
- Use database constraints in addition to model validations
- Avoid complex callback chains (max 2-3 callbacks)
- Prefer explicit service objects over `after_*` callbacks for side effects
- Use `validate` for custom validation methods

### RESTful Design
- Follow RESTful conventions for routes and actions
- Use standard actions: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`
- Use nested routes sparingly (max 1 level deep)
- Custom actions should be rare - consider separate controllers instead

### Performance
- Use caching strategies (`Rails.cache`, fragment caching, Russian Doll caching)
- Move long-running tasks to background jobs (Sidekiq, DelayedJob)
- Use `counter_cache` for association counts
- Use `preload` or `eager_load` to avoid N+1 queries

## Security Guidelines

### SQL Injection Prevention
- NEVER use string interpolation or concatenation in queries
- Always use parameterized queries with placeholders
- Bad: `User.where("email = '#{params[:email]}'")`
- Good: `User.where("email = ?", params[:email])` or `User.where(email: params[:email])`
- Avoid raw SQL when possible - use ActiveRecord query methods

### Cross-Site Scripting (XSS) Prevention
- Rails escapes HTML by default in ERB templates
- Only use `raw` or `html_safe` when absolutely necessary and content is trusted
- Sanitize user input with `sanitize` helper for rich text
- Use tag helpers (`tag.div`, `tag.span`, etc.) instead of raw HTML strings in helpers
- Be cautious with JSON rendering - use `json_escape` or `j` helper

### CSRF Protection
- Keep `protect_from_forgery with: :exception` in ApplicationController
- Use `form_with` or `form_for` helpers (they include CSRF tokens automatically)
- For AJAX requests, include CSRF token in headers
- Don't disable CSRF protection unless you have alternative protection (e.g., API with token auth)

### Mass Assignment Protection
- Always use Strong Parameters (see Rails-Specific section)
- Never pass params directly to `create`, `update`, or `new`
- Be explicit about permitted attributes
- Use `attr_readonly` for attributes that should never be updated after creation

### Authentication and Authorization
- Use established gems like Devise, Sorcery for authentication
- Implement authorization with Pundit or CanCanCan
- Never store passwords in plain text
- Use `has_secure_password` for password encryption
- Implement proper session management and timeout
- Use secure cookies: `secure: true, httponly: true, same_site: :lax`

### Sensitive Data Handling
- Use Rails encrypted credentials for secrets (`rails credentials:edit`)
- Alternative: Use environment variables with gems like `dotenv-rails` (load via `ENV['KEY_NAME']`)
- Never commit `.env` files or credentials to version control
- Use `Rails.application.credentials` to access secrets
- Encrypt sensitive database columns with `encrypts` (Rails 7+)
- Filter sensitive parameters in logs: `config.filter_parameters += [:password, :ssn, :credit_card]`

### Additional Security Measures
- Keep Rails and gems up to date - run `bundle audit` regularly
- Use HTTPS in production (`config.force_ssl = true`)
- Implement rate limiting for API endpoints and login attempts
- Validate and sanitize file uploads
- Use security headers (Content-Security-Policy, X-Frame-Options, etc.)
- Implement proper error handling - don't expose stack traces in production

## Performance Guidelines

### Database Query Optimization
1. **N+1 Query Prevention** (see Rails-Specific section)
   - Use `preload` or `eager_load` to load associations
   - Run `bullet` gem in development to detect issues
   - Monitor queries in logs and APM tools

2. **Efficient Querying**
   - Use `select` to fetch only needed columns: `User.select(:id, :name)`
   - Use `pluck` for single or few columns instead of loading full records
   - Use `exists?` instead of `present?` or `any?` for existence checks
   - Use `find_each` or `in_batches` for large datasets (default batch size: 1000)
   - Avoid `count` on already loaded collections - use `size` or `length` instead

3. **Database Indexes**
   - Add indexes to foreign keys and frequently queried columns
   - Use composite indexes for queries with multiple WHERE conditions
   - Monitor slow queries and add indexes accordingly
   - Don't over-index - each index has write performance cost

4. **Query Scoping and Limiting**
   - Always use `limit` for queries that don't need all records
   - Use pagination gems like `kaminari` or `pagy`
   - Avoid `offset` for large offsets - use cursor-based pagination instead

### Caching Strategies
1. **Fragment Caching**
   - Cache expensive view partials with `cache` helper
   - Use Russian Doll caching for nested fragments
   - Set appropriate cache keys with versioning: `cache [@user, @post]`

2. **Query Caching**
   - Use `Rails.cache.fetch` for expensive queries
   - Set appropriate TTL (time-to-live) values
   - Use `counter_cache` for association counts instead of `posts.count`

3. **Low-Level Caching**
   - Cache computed values with `Rails.cache.fetch(key) { expensive_operation }`
   - Use appropriate cache stores (Redis, Memcached) for production
   - Implement cache expiration strategies

### Background Jobs
- Move long-running tasks to background jobs (Sidekiq, GoodJob, etc.)
- Examples: sending emails, processing uploads, external API calls
- Use `perform_later` for ActiveJob: `UserMailer.welcome_email(@user).deliver_later`
- Set appropriate queue priorities and retry strategies
- Monitor job queue depth and processing times

### Asset and View Optimization
- Use asset pipeline or Propshaft for asset management
- Enable asset compression and minification in production
- Use CDN for static assets
- Lazy load images and use responsive images
- Minimize database queries in views - prepare data in controller/presenter

### Memory Management
- Avoid loading large datasets into memory at once
- Use streaming for large file downloads: `send_file` with streaming
- Clear associations when not needed: `posts.clear` instead of `posts = []`
- Monitor memory usage with tools like `memory_profiler` or `derailed_benchmarks`

### Application-Level Optimization
- Use database-level uniqueness constraints with `validates_uniqueness_of` (add index)
- Avoid expensive calculations in loops - memoize when possible
- Use `||=` for memoization: `@users ||= User.active`
- Profile slow endpoints with `rack-mini-profiler` or APM tools
- Consider denormalization for read-heavy tables

## Testing Guidelines (RSpec)

Follow the RSpec Style Guide (https://github.com/rubocop/rspec-style-guide) as the baseline. The custom rules below take precedence over the standard guide when there are conflicts.

### Test Structure and Organization
1. **File Organization**
   - Mirror the structure of `app/` in `spec/`
   - Place model specs in `spec/models/`
   - Place request specs in `spec/requests/` with naming pattern `*_request_spec.rb`
   - DO NOT create controller specs - use request specs instead
   - Use `spec/support/` for shared contexts, helpers, and custom matchers
   - One spec file per class/module

2. **Describe and Context Blocks**
   - Use `describe` for things (classes, methods)
   - Use `context` for states or conditions
   - Method names: `describe '#instance_method'` and `describe '.class_method'`
   - Use descriptive context names: `context 'when user is admin'`

3. **Test Structure (AAA Pattern)**
   - Arrange: Set up test data and conditions
   - Act: Execute the code under test
   - Assert: Verify the results
   - Keep each test focused on a single behavior

### RSpec Best Practices
1. **let and subject**
   - Use `let` for memoized helper methods
   - Use `let!` when you need immediate evaluation
   - Define `subject` explicitly when testing a specific object
   - Avoid using `subject` implicitly - be explicit

2. **Factory Usage**
   - Use FactoryBot for test data creation
   - Prefer `build` over `create` when persistence is not needed
   - Use `build_stubbed` for even faster tests (no database)
   - Define traits for variations: `create(:user, :admin)`
   - Keep factories lean - only set required attributes

3. **Expectations and Matchers**
   - Use one expectation per example when possible
   - Prefer specific matchers: `expect(user).to be_valid` over `expect(user.valid?).to be true`
   - Use custom matchers for complex or repeated assertions
   - Prefer `aggregate_failures` for multiple related expectations

4. **Mocking and Stubbing**
   - Use mocks/stubs sparingly - prefer real objects when possible
   - Stub external dependencies (APIs, file system, time)
   - Use `allow` for stubs, `expect` for mocks
   - Verify important interactions, don't over-specify

### Test Types and Coverage
1. **Model Specs**
   - Test validations, associations, scopes
   - Test custom methods and business logic
   - Test edge cases and error conditions
   - Use `shoulda-matchers` for concise validation tests

2. **Request Specs** (preferred over controller specs)
   - Place in `spec/requests/` with naming pattern `*_request_spec.rb`
   - Test full request/response cycle
   - Verify HTTP status codes, response bodies, redirects
   - Test authentication and authorization
   - Cover happy paths and error cases
   - Example: `spec/requests/users_request_spec.rb` for UsersController

3. **System/Feature Specs**
   - Test user workflows end-to-end
   - Use realistic user interactions
   - Keep scenarios focused and readable
   - Use `js: true` only when necessary (slower)

4. **Service/Interactor Specs**
   - Test business logic in service objects
   - Cover success and failure paths
   - Test side effects and state changes
   - Mock external dependencies

### Performance and Maintenance
- Run tests in random order to avoid dependencies
- Use database cleaner strategies appropriately (transaction > truncation)
- Tag slow tests and run separately: `rspec --tag ~slow`
- Aim for fast test suite (under 1 minute for unit tests)
- Use shared examples for repeated test patterns
- Keep tests DRY but readable - don't over-abstract

### Common Patterns
```ruby
# Good: Explicit and readable
describe User do
  describe '#full_name' do
    let(:user) { build(:user, first_name: 'John', last_name: 'Doe') }

    it 'returns first and last name combined' do
      expect(user.full_name).to eq('John Doe')
    end
  end

  context 'when user is admin' do
    let(:admin) { create(:user, :admin) }

    it 'has admin privileges' do
      expect(admin).to be_admin
    end
  end
end
```

## Maintainability Guidelines

### DRY Principle (Don't Repeat Yourself)
- Extract repeated logic into methods, modules, or service objects
- Use concerns for shared model/controller behavior
- Create helper methods for common view logic
- Use inheritance and composition appropriately
- Don't over-DRY - readability is more important than eliminating all duplication

### Code Complexity
1. **Method Length**
   - Keep methods short and focused (< 10 lines ideally, max 20)
   - One method should do one thing
   - Extract complex logic into private methods or service objects

2. **Cyclomatic Complexity**
   - Avoid deeply nested conditionals (max 2-3 levels)
   - Use guard clauses for early returns
   - Prefer polymorphism over complex conditionals
   - Break complex methods into smaller pieces

3. **Class Responsibilities**
   - Follow Single Responsibility Principle (SRP)
   - Keep models focused on data and simple business logic
   - Use service objects for complex business logic
   - Use presenters/decorators for view-specific logic
   - Controllers should only orchestrate - delegate to models/services

### Code Organization
1. **Naming and Clarity**
   - Use clear, descriptive names for methods, variables, classes
   - Prefer explicit over clever code
   - Name booleans as questions: `active?`, `valid?`, `published?`
   - Use meaningful constant names instead of magic numbers

2. **Comments and Documentation**
   - Write self-documenting code - good names over comments
   - Add comments for complex business logic or non-obvious decisions
   - Document public APIs and interfaces
   - Keep comments up-to-date with code changes
   - Use YARD or RDoc for API documentation when needed

3. **File Structure**
   - Keep related code together
   - One class per file (matching class name)
   - Organize code logically within classes: constants, associations, validations, scopes, public methods, private methods
   - Group related private methods together

### Dependency Management
- Keep `Gemfile` organized with comments for gem purposes
- Pin gem versions or use pessimistic versioning: `~> 3.2.0`
- Regularly update dependencies: `bundle update`
- Remove unused gems
- Use `bundle audit` to check for security vulnerabilities
- Document why specific gem versions are pinned

### Code Smells to Avoid
1. **Long Parameter Lists**
   - Extract parameter objects or use keyword arguments
   - Max 3-4 parameters per method

2. **Feature Envy**
   - Methods should use data from their own class
   - If a method uses another object's data heavily, consider moving it

3. **Data Clumps**
   - Group related data into objects (Value Objects, DTOs)

4. **Large Classes**
   - Extract responsibilities into separate classes
   - Use modules for mixins, but don't abuse

5. **Shotgun Surgery**
   - Changes shouldn't require modifications across many files
   - Improve cohesion and reduce coupling

### Refactoring Practices
- Refactor continuously, not in big batches
- Write tests before refactoring (safety net)
- Make small, incremental changes
- Run tests after each refactoring step
- Use linters and code analysis tools: RuboCop, Reek, Brakeman
- Review code regularly - pair programming, code reviews

### Technical Debt Management
- Document technical debt with TODO/FIXME comments
- Track technical debt in issue tracker
- Allocate time for paying down technical debt
- Don't let "temporary" solutions become permanent
- Refactor before adding new features to problematic areas
