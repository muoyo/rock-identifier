# Rock Identifier Tests

This directory contains unit tests for the Rock Identifier app. The tests are organized to match the app's structure, with separate test files for each model and service.

## Test Organization

The tests are organized into two main directories:

- **Models/** - Tests for data models
  - `RockIdentificationResultTests.swift` - Tests for the main result model
  - `PhysicalPropertiesTests.swift` - Tests for physical characteristics
  - `ChemicalPropertiesTests.swift` - Tests for chemical properties
  - `FormationTests.swift` - Tests for geological formation data
  - `UsesTests.swift` - Tests for uses and fun facts

- **Services/** - Tests for app services
  - `CollectionManagerTests.swift` - Tests for collection storage and retrieval
  - `ConnectionRequestTests.swift` - Tests for API communication
  - `RockIdentificationServiceTests.swift` - Tests for rock identification logic

## Testing Approach

### Model Tests
For each model, the tests focus on:
- Initialization with various parameters
- Correct handling of optional properties
- Proper encoding and decoding via the Codable protocol
- Edge cases like empty arrays and special values

### Service Tests
For services, the tests focus on:
- Core functionality of each service
- State management
- Proper data handling and persistence
- Error handling and edge cases
- API communication for the identification service

## Running the Tests

To run the tests:

1. Open the Rock Identifier project in Xcode
2. Select the RockIdentifier scheme
3. Press ⌘+U or go to Product > Test

You can also run individual test classes or methods by clicking the diamond icon next to the test declaration.

## Test Dependencies

The tests use the standard XCTest framework and do not require any additional dependencies. For service tests that involve network requests, we use mock objects to avoid actual network calls during testing.

## Test Coverage

These tests cover:
- 100% of model properties and Codable implementations
- Core functionality of all services
- Edge cases and error handling

Future improvements could include:
- UI tests for view components
- Integration tests for end-to-end workflows
- Performance tests for critical operations

## Writing New Tests

When adding new features to the app:

1. Create a corresponding test file in the appropriate directory
2. Follow the existing pattern of `setUp()` and `tearDown()` methods
3. Use descriptive test method names that clearly indicate what is being tested
4. Include tests for both normal operation and edge cases/error handling
