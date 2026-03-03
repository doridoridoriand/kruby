# Design Document: Kubernetes Ruby Client Test Implementation

## Overview

This design document outlines the architecture and implementation strategy for comprehensive test coverage of the Kubernetes Ruby client library. The design builds upon existing tests (both OpenAPI Generator-generated and manually written) and introduces new testing patterns inspired by the Go client-go and Python client implementations.

The test suite will use RSpec as the testing framework and will include unit tests, integration tests, and property-based tests to ensure correctness across a wide range of inputs and scenarios.

## Architecture

### Test Organization

```
kubernetes/
├── spec/
│   ├── api_client_spec.rb          # Generated + enhanced API client tests
│   ├── configuration_spec.rb        # Generated + enhanced configuration tests
│   ├── utils_spec.rb                # Utility function tests
│   ├── watch_spec.rb                # Watch functionality tests
│   ├── config/
│   │   ├── incluster_config_spec.rb
│   │   ├── kube_config_spec.rb
│   │   └── matchers.rb
│   ├── resources/                   # NEW: Resource operation tests
│   │   ├── pod_spec.rb
│   │   ├── deployment_spec.rb
│   │   ├── service_spec.rb
│   │   └── common_operations_spec.rb
│   ├── fake/                        # NEW: Fake client implementation
│   │   ├── fake_client.rb
│   │   └── fake_client_spec.rb
│   ├── properties/                  # NEW: Property-based tests
│   │   ├── serialization_properties_spec.rb
│   │   ├── selector_properties_spec.rb
│   │   └── url_properties_spec.rb
│   ├── integration/                 # NEW: Integration tests
│   │   ├── cluster_operations_spec.rb
│   │   └── watch_integration_spec.rb
│   ├── fixtures/
│   │   ├── config/
│   │   ├── files/
│   │   └── resources/               # NEW: Sample resource fixtures
│   ├── helpers/
│   │   ├── file_fixtures.rb
│   │   ├── resource_helpers.rb      # NEW
│   │   └── cluster_helpers.rb       # NEW
│   └── spec_helper.rb
```

## Components and Interfaces

### 1. Fake Client Implementation

The Fake Client provides an in-memory implementation of the Kubernetes API client interface for fast, isolated unit testing.

**Interface:**
```ruby
module Kubernetes
  module Fake
    class Client
      # Implements the same interface as Kubernetes::ApiClient
      def initialize(config = Configuration.new)
      def call_api(http_method, path, opts = {})
      
      # Internal storage
      def store
      def reset!
    end
    
    class Store
      # In-memory storage for resources
      def create(resource_type, namespace, resource)
      def get(resource_type, namespace, name)
      def list(resource_type, namespace, opts = {})
      def update(resource_type, namespace, name, resource)
      def delete(resource_type, namespace, name, opts = {})
      def watch(resource_type, namespace, opts = {})
    end
  end
end
```

**Key Features:**
- Implements same interface as real client
- Stores resources in memory with proper namespacing
- Supports label selectors and field selectors
- Maintains resource versions for optimistic concurrency
- Generates watch events for modifications

### 2. Resource Test Helpers

Shared helpers for creating and manipulating test resources.

**Interface:**
```ruby
module Kubernetes
  module Testing
    module ResourceHelpers
      # Create sample resources
      def sample_pod(name: 'test-pod', namespace: 'default', **opts)
      def sample_deployment(name: 'test-deployment', namespace: 'default', **opts)
      def sample_service(name: 'test-service', namespace: 'default', **opts)
      
      # Assertions
      def expect_resource_created(resource)
      def expect_resource_updated(resource, old_version)
      def expect_resource_deleted(resource)
      
      # Label selector helpers
      def with_labels(labels)
      def matching_selector(selector)
    end
  end
end
```

### 3. Property-Based Testing Framework

Integration with RSpec for property-based testing using the `rantly` gem.

**Interface:**
```ruby
module Kubernetes
  module Testing
    module Properties
      # Property test DSL
      def property(description, iterations: 100, &block)
      
      # Generators
      def arbitrary_pod
      def arbitrary_label_selector
      def arbitrary_resource_version
      def arbitrary_url_params
    end
  end
end
```

### 4. Integration Test Helpers

Helpers for running tests against real Kubernetes clusters.

**Interface:**
```ruby
module Kubernetes
  module Testing
    module ClusterHelpers
      # Cluster detection
      def cluster_available?
      def skip_unless_cluster_available
      
      # Resource cleanup
      def with_cleanup(namespace: 'test', &block)
      def cleanup_namespace(namespace)
      
      # Cluster setup
      def ensure_test_namespace(namespace)
      def wait_for_resource(resource_type, name, namespace, timeout: 30)
    end
  end
end
```

## Data Models

### Fake Client Store Structure

```ruby
{
  'pods' => {
    'default' => {
      'pod-1' => {
        metadata: { name: 'pod-1', namespace: 'default', resourceVersion: '1', ... },
        spec: { ... },
        status: { ... }
      }
    },
    'kube-system' => { ... }
  },
  'deployments' => { ... },
  'services' => { ... }
}
```

### Test Fixture Format

```yaml
# spec/fixtures/resources/sample_pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: default
  labels:
    app: test
spec:
  containers:
  - name: nginx
    image: nginx:latest
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property Reflection

After analyzing all acceptance criteria, several properties can be consolidated:

**Consolidations:**
- Properties 1.1, 1.2, 1.3 (HTTP methods, status codes, errors) can be combined into comprehensive API client behavior properties
- Properties 3.1-3.4 (CRUD operations) share common patterns and can be unified
- Properties 4.1, 4.3, 4.4 (watch event handling) can be combined into watch stream properties
- Properties 5.2-5.5 (fake client operations) test the same underlying storage mechanism

**Unique Properties Retained:**
- Serialization round-trips (1.4, 7.1) - fundamental correctness
- Configuration parsing (2.1-2.4) - each tests different config sources
- Label selector matching (7.2) - complex matching logic
- Resource version handling (7.3) - ordering semantics
- URL construction (7.4) - encoding and parameter handling

### Correctness Properties

#### Property 1: Serialization Round-Trip Integrity

*For any* valid Kubernetes resource object, serializing to JSON and then deserializing back should produce an equivalent object with the same semantic content.

**Validates: Requirements 1.4, 7.1**

**Implementation Strategy:**
- Generate arbitrary Kubernetes resources (Pods, Deployments, Services, etc.)
- Serialize using `to_json` or equivalent
- Deserialize using the API client's deserialize method
- Verify all fields match (allowing for default value insertion)

#### Property 2: HTTP Request Construction Correctness

*For any* HTTP method (GET, POST, PUT, PATCH, DELETE) and valid parameters, the API client should construct a request with the correct method, path, headers, and body encoding.

**Validates: Requirements 1.1**

**Implementation Strategy:**
- Generate random HTTP methods and parameters
- Build request using `build_request`
- Verify request object has correct method, URL, headers, and body
- Verify query parameters are properly encoded

#### Property 3: HTTP Response Handling Consistency

*For any* HTTP status code, the API client should handle the response consistently: success for 2xx, client errors for 4xx, server errors for 5xx.

**Validates: Requirements 1.2, 1.3**

**Implementation Strategy:**
- Generate random status codes across all ranges
- Mock responses with those status codes
- Verify 2xx returns success, 4xx/5xx raise appropriate exceptions
- Verify error messages contain useful information

#### Property 4: Authentication Header Correctness

*For any* authentication configuration (bearer token, client cert, basic auth), the API client should set the correct Authorization header in requests.

**Validates: Requirements 1.5**

**Implementation Strategy:**
- Generate random authentication configurations
- Build requests with those configurations
- Verify Authorization header matches expected format
- Verify credentials are not logged or exposed

#### Property 5: Configuration Parsing Idempotence

*For any* valid kubeconfig file, parsing it multiple times should produce the same configuration object.

**Validates: Requirements 2.1**

**Implementation Strategy:**
- Generate various kubeconfig structures
- Parse the same config multiple times
- Verify all parsed configurations are equivalent
- Verify no side effects from repeated parsing

#### Property 6: Configuration Validation Completeness

*For any* invalid configuration (missing required fields, invalid values), the configuration loader should reject it with a descriptive error message.

**Validates: Requirements 2.3**

**Implementation Strategy:**
- Generate invalid configurations (missing host, invalid certs, etc.)
- Attempt to load each configuration
- Verify ConfigError is raised
- Verify error message describes the specific problem

#### Property 7: Resource CRUD Operation Consistency

*For any* Kubernetes resource type, creating a resource should allow it to be read back, updating should increment the resource version, and deleting should make it unavailable.

**Validates: Requirements 3.1, 3.3, 3.4**

**Implementation Strategy:**
- Generate arbitrary resources of various types
- Create → verify readable with same content
- Update → verify resource version incremented
- Delete → verify subsequent read fails
- Test with fake client for fast execution

#### Property 8: Label Selector Matching Correctness

*For any* label selector and set of resources, the selector should match exactly those resources whose labels satisfy the selector expression.

**Validates: Requirements 3.2, 7.2**

**Implementation Strategy:**
- Generate random label selectors (equality, set-based)
- Generate random resources with various labels
- Apply selector and verify matches
- Verify non-matching resources are excluded
- Test edge cases: empty selectors, empty labels

#### Property 9: Pagination Continuation Consistency

*For any* list operation with pagination, using the continuation token should return the next page without duplicates or gaps.

**Validates: Requirements 3.5**

**Implementation Strategy:**
- Create a large set of resources
- List with small page size
- Follow continuation tokens
- Verify all resources appear exactly once
- Verify order is consistent

#### Property 10: Watch Event Stream Correctness

*For any* sequence of resource modifications, the watch stream should emit events in the correct order (ADDED, MODIFIED, DELETED) with accurate resource versions.

**Validates: Requirements 4.1, 4.4**

**Implementation Strategy:**
- Generate random resource modification sequences
- Watch the resource
- Verify events match the modifications
- Verify resource versions are monotonically increasing
- Verify event types are correct

#### Property 11: Watch Stream Resilience

*For any* watch stream, receiving malformed JSON lines should not crash the watch or affect subsequent valid events.

**Validates: Requirements 4.3**

**Implementation Strategy:**
- Generate watch streams with interspersed malformed JSON
- Verify watch continues processing after errors
- Verify valid events are still parsed correctly
- Verify error callbacks are invoked appropriately

#### Property 12: Concurrent Watch Isolation

*For any* set of concurrent watch operations, each watch should receive only its own events without interference from other watches.

**Validates: Requirements 4.5**

**Implementation Strategy:**
- Start multiple watches on different resources
- Generate events for each resource
- Verify each watch receives only its events
- Verify no cross-contamination between watches

#### Property 13: Fake Client Storage Consistency

*For any* sequence of operations (create, read, update, delete) on the fake client, the in-memory storage should maintain consistency with resource versions incrementing and deleted resources being unavailable.

**Validates: Requirements 5.2, 5.3, 5.4**

**Implementation Strategy:**
- Generate random operation sequences
- Execute on fake client
- Verify storage state matches expected state
- Verify resource versions are correct
- Verify deleted resources return 404

#### Property 14: Fake Client Selector Filtering

*For any* label selector, the fake client's list operation should return exactly those resources whose labels match the selector.

**Validates: Requirements 5.5**

**Implementation Strategy:**
- Populate fake client with random resources
- Generate random label selectors
- List with selector
- Verify all returned resources match
- Verify no matching resources are excluded

#### Property 15: Error Response Parsing Completeness

*For any* API error response (validation errors, conflicts, etc.), the client should extract and expose all relevant error details.

**Validates: Requirements 6.2, 6.5**

**Implementation Strategy:**
- Generate various error response formats
- Parse error responses
- Verify error details are extracted
- Verify error messages are informative
- Verify unexpected formats don't crash

#### Property 16: Resource Version Ordering

*For any* two resource versions, comparison should establish a total ordering where newer versions are always greater than older versions.

**Validates: Requirements 7.3**

**Implementation Strategy:**
- Generate sequences of resource versions
- Compare all pairs
- Verify transitivity: if A < B and B < C, then A < C
- Verify antisymmetry: if A < B, then not B < A
- Verify totality: for any A and B, either A < B, A = B, or A > B

#### Property 17: URL Construction Validity

*For any* set of query parameters, the constructed URL should be valid, properly encoded, and parseable back to the original parameters.

**Validates: Requirements 7.4**

**Implementation Strategy:**
- Generate random query parameters (including special characters)
- Construct URL
- Verify URL is valid (parseable by URI library)
- Verify parameters are properly percent-encoded
- Parse URL and verify parameters match original

## Error Handling

### Error Categories

1. **Network Errors**
   - Connection failures → `Kubernetes::NetworkError`
   - Timeouts → `Kubernetes::TimeoutError`
   - DNS resolution failures → `Kubernetes::NetworkError`

2. **API Errors**
   - 400 Bad Request → `Kubernetes::BadRequestError` with validation details
   - 401 Unauthorized → `Kubernetes::UnauthorizedError`
   - 403 Forbidden → `Kubernetes::ForbiddenError`
   - 404 Not Found → `Kubernetes::NotFoundError`
   - 409 Conflict → `Kubernetes::ConflictError` with resource version info
   - 422 Unprocessable Entity → `Kubernetes::ValidationError` with field errors
   - 500 Internal Server Error → `Kubernetes::ServerError`
   - 503 Service Unavailable → `Kubernetes::ServiceUnavailableError`

3. **Configuration Errors**
   - Missing required fields → `Kubernetes::ConfigError` with field name
   - Invalid file paths → `Kubernetes::ConfigError` with path
   - Invalid credentials → `Kubernetes::ConfigError` with credential type

4. **Watch Errors**
   - Stream interruption → Automatic reconnection with exponential backoff
   - Malformed events → Log warning, continue processing
   - Resource version too old → Restart watch from current version

### Error Handling Strategies

**Retry Logic:**
- Network errors: Retry up to 3 times with exponential backoff
- 429 Rate Limit: Retry with backoff based on Retry-After header
- 500/503 Server errors: Retry up to 2 times
- Other errors: No automatic retry

**Error Context:**
- All errors include the HTTP method and path
- API errors include the response body
- Configuration errors include the file path and line number
- Watch errors include the resource type and namespace

## Testing Strategy

### Test Pyramid

```
        /\
       /  \
      / E2E\          Integration Tests (5%)
     /------\         - Real cluster operations
    /        \        - End-to-end workflows
   / Integr. \       
  /------------\      
 /              \     Unit Tests (70%)
/   Unit Tests  \    - Fake client
\----------------/   - Mocked HTTP
 \              /    - Fast, isolated
  \   Property /     
   \   Tests  /      Property Tests (25%)
    \--------/       - 100+ iterations each
     \      /        - Random inputs
      \    /         - Universal properties
       \  /
        \/
```

### Test Execution

**Unit Tests:**
- Run with: `bundle exec rspec spec --tag ~integration --tag ~property`
- Should complete in < 30 seconds
- No external dependencies
- Use fake client and mocks

**Property Tests:**
- Run with: `bundle exec rspec spec --tag property`
- Each property runs 100 iterations
- Should complete in < 60 seconds
- Use `rantly` gem for random generation

**Integration Tests:**
- Run with: `bundle exec rspec spec --tag integration`
- Require a Kubernetes cluster (kind, minikube, or remote)
- Should complete in < 5 minutes
- Automatic cleanup after each test

**All Tests:**
- Run with: `bundle exec rspec spec`
- CI/CD should run all tests
- Coverage target: 80% for core functionality

### Property-Based Testing Configuration

**Framework:** Use the `rantly` gem for property-based testing in Ruby.

```ruby
# Example property test structure
RSpec.describe 'Serialization', :property do
  it 'round-trips correctly' do
    property_of {
      # Generate arbitrary pod
      arbitrary_pod
    }.check(100) { |pod|
      # Serialize and deserialize
      json = pod.to_json
      deserialized = Kubernetes::V1Pod.from_json(json)
      
      # Verify equivalence
      expect(deserialized).to be_equivalent_to(pod)
    }
  end
end
```

**Test Tags:**
- Each property test must be tagged with `:property`
- Each property test must reference its design property number in a comment
- Format: `# Feature: test-implementation, Property N: <property description>`

**Generators:**
- Create custom generators for Kubernetes resources
- Ensure generated resources are valid
- Include edge cases in generation (empty strings, nil values, large numbers)

### Test Organization Principles

1. **Generated Tests:** Keep OpenAPI Generator tests unmodified in their original files
2. **Enhanced Tests:** Add manual tests in separate `_enhanced_spec.rb` files
3. **New Tests:** Organize by functionality (resources, properties, integration)
4. **Shared Code:** Extract common helpers and fixtures to `spec/helpers/` and `spec/fixtures/`
5. **Test Data:** Use YAML fixtures for complex test data, inline for simple cases

### Coverage Goals

| Component | Target Coverage | Priority |
|-----------|----------------|----------|
| API Client | 90% | High |
| Configuration | 85% | High |
| Resource Operations | 80% | High |
| Watch | 85% | High |
| Fake Client | 95% | High |
| Utilities | 75% | Medium |
| Generated Code | 70% | Low |

### Continuous Integration

**Pre-commit:**
- Run unit tests
- Run property tests
- Check code coverage

**Pull Request:**
- Run all unit tests
- Run all property tests
- Run integration tests (if cluster available)
- Generate coverage report
- Verify coverage meets targets

**Nightly:**
- Run all tests including integration
- Run extended property tests (1000 iterations)
- Generate detailed coverage report
- Performance benchmarks

## Implementation Notes

### Dependencies

**Testing Gems:**
```ruby
# Gemfile
group :test do
  gem 'rspec', '~> 3.12'
  gem 'webmock', '~> 3.18'      # HTTP mocking
  gem 'rantly', '~> 2.0'        # Property-based testing
  gem 'simplecov', '~> 0.22'    # Code coverage
  gem 'timecop', '~> 0.9'       # Time manipulation
end
```

### Fake Client Implementation Strategy

1. **Phase 1:** Implement basic storage (create, read, delete)
2. **Phase 2:** Add update and resource version handling
3. **Phase 3:** Implement label selector filtering
4. **Phase 4:** Add watch event generation
5. **Phase 5:** Optimize for performance

### Migration Path

1. **Week 1:** Set up property testing framework and fake client skeleton
2. **Week 2:** Implement core fake client functionality
3. **Week 3:** Add property tests for serialization and API client
4. **Week 4:** Add resource operation tests
5. **Week 5:** Add watch and integration tests
6. **Week 6:** Documentation and polish

## References

- [Go client-go testing patterns](https://github.com/kubernetes/client-go)
- [Python client testing patterns](https://github.com/kubernetes-client/python)
- [RSpec best practices](https://rspec.info/)
- [Rantly property testing](https://github.com/abargnesi/rantly)
- [Kubernetes API conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md)
