# QRCodeApp - Agent Development Guide

This document provides essential information for AI coding agents working on the QRCodeApp macOS project.

## Project Overview

- **Project Name**: QRCodeApp
- **Platform**: macOS
- **Framework**: SwiftUI
- **Xcode Version**: 26.1.1
- **Language**: Swift
- **Project Format**: Xcode Project (.xcodeproj)

### Project Structure

```
QRCodeApp/
├── QRCodeApp/                    # Main application target
│   ├── QRCodeAppApp.swift        # App entry point
│   ├── ContentView.swift         # Main view
│   └── Assets.xcassets/          # Asset catalog
├── QRCodeAppTests/               # Unit tests target
│   └── QRCodeAppTests.swift      # Unit test suite
├── QRCodeAppUITests/             # UI tests target
│   ├── QRCodeAppUITests.swift    # UI test suite
│   └── QRCodeAppUITestsLaunchTests.swift
└── QRCodeApp.xcodeproj/          # Xcode project file
```

### Targets

1. **QRCodeApp** - Main application (com.apple.product-type.application)
2. **QRCodeAppTests** - Unit test bundle (com.apple.product-type.bundle.unit-test)
3. **QRCodeAppUITests** - UI test bundle (com.apple.product-type.bundle.ui-testing)

---

## Unit Tests

### Testing Framework

- **Framework**: XCTest (Apple's native testing framework)
- **Test Targets**: 
  - `QRCodeAppTests` - Unit and integration tests
  - `QRCodeAppUITests` - UI automation tests

### Testing Best Practices

1. **Use XCTest for Unit and UI Tests**
   - Import XCTest framework: `import XCTest`
   - Import the app module: `@testable import QRCodeApp`
   - Inherit from `XCTestCase` for test classes

2. **Test-Driven Development Workflow**
   - ✅ **Run tests before making changes** - Establish baseline
   - ✅ **Add tests to verify changes** - Write tests for new functionality
   - ✅ **Ensure tests pass** - Verify all tests pass before completing session
   - ✅ **Fix failing tests** - Never leave broken tests

3. **Unit Test Structure**
   ```swift
   import XCTest
   @testable import QRCodeApp
   
   final class MyFeatureTests: XCTestCase {
       override func setUpWithError() throws {
           // Setup code before each test
       }
       
       override func tearDownWithError() throws {
           // Cleanup code after each test
       }
       
       func testFeatureBehavior() throws {
           // Arrange
           // Act
           // Assert
       }
   }
   ```

4. **UI Test Structure**
   ```swift
   import XCTest
   
   final class MyUITests: XCTestCase {
       @MainActor
       func testUIInteraction() throws {
           let app = XCUIApplication()
           app.launch()
           
           // Perform UI interactions and assertions
       }
   }
   ```

5. **Performance Testing**
   ```swift
   func testPerformanceExample() throws {
       self.measure {
           // Code to measure performance
       }
   }
   ```

### Running Tests

```bash
# Run all tests with formatted output
xcodebuild test -scheme QRCodeApp 2>&1 | xcsift -w

# Run specific test target
xcodebuild test -scheme QRCodeApp -only-testing:QRCodeAppTests 2>&1 | xcsift -w
xcodebuild test -scheme QRCodeApp -only-testing:QRCodeAppUITests 2>&1 | xcsift -w

# Run specific test class
xcodebuild test -scheme QRCodeApp -only-testing:QRCodeAppTests/QRCodeAppTests 2>&1 | xcsift -w

# Run specific test method
xcodebuild test -scheme QRCodeApp -only-testing:QRCodeAppTests/QRCodeAppTests/testExample 2>&1 | xcsift -w
```

---

## xcodebuild

### Using xcsift for Context Efficiency

**CRITICAL**: Always use `xcsift` to format xcodebuild output. This tool parses build output into structured JSON, making it easier for agents to process and reducing context consumption.

### xcsift Overview

- **Purpose**: Parse and format xcodebuild/Swift output for coding agents
- **Input**: xcodebuild or Swift command output via stdin
- **Output**: Structured JSON with errors, warnings, and build information
- **Installation**: Already installed at `/opt/homebrew/bin/xcsift`

### Important: Redirect stderr to stdout

Always use `2>&1` to capture all compiler errors, warnings, and build output:

```bash
xcodebuild [command] 2>&1 | xcsift -w
```

### Common xcsift Commands

```bash
# Build the project
xcodebuild build -scheme QRCodeApp 2>&1 | xcsift -w

# Run tests
xcodebuild test -scheme QRCodeApp 2>&1 | xcsift -w

# Clean build folder
xcodebuild clean -scheme QRCodeApp 2>&1 | xcsift -w

# Archive the app
xcodebuild archive -scheme QRCodeApp -archivePath ./build/QRCodeApp.xcarchive 2>&1 | xcsift -w

# Swift build (if using SPM)
swift build 2>&1 | xcsift -w

# Swift test (if using SPM)
swift test 2>&1 | xcsift -w
```

### xcsift Flags

- `-w` - Include warnings in output
- Use without flags to show only errors

### Build Configuration

```bash
# Build for different configurations
xcodebuild build -scheme QRCodeApp -configuration Debug 2>&1 | xcsift -w
xcodebuild build -scheme QRCodeApp -configuration Release 2>&1 | xcsift -w
```

### Destination Specifications

```bash
# Build for specific destination
xcodebuild build -scheme QRCodeApp -destination 'platform=macOS' 2>&1 | xcsift -w

# List available destinations
xcodebuild -showdestinations -scheme QRCodeApp
```

---

## Structure Hygiene

### Code Quality Standards

**CRITICAL**: Fix all errors, warnings, and failed tests - even if unrelated to current changes.

### Pre-Change Checklist

1. ✅ Build the project: `xcodebuild build -scheme QRCodeApp 2>&1 | xcsift -w`
2. ✅ Check for warnings: Review xcsift output for all warnings
3. ✅ Run all tests: `xcodebuild test -scheme QRCodeApp 2>&1 | xcsift -w`
4. ✅ Document baseline state

### Post-Change Checklist

1. ✅ Fix all compilation errors
2. ✅ Resolve all warnings (Swift compiler, static analyzer, etc.)
3. ✅ Ensure all tests pass
4. ✅ Fix any newly introduced test failures
5. ✅ Address any existing failing tests
6. ✅ Verify no regressions

### Common Issues to Address

- **Compiler Warnings**: Unused variables, deprecated APIs, type mismatches
- **Swift Warnings**: Optionals, casting, protocol conformance
- **Test Failures**: Assertion failures, timeouts, setup issues
- **Build Errors**: Missing files, framework issues, signing problems
- **Static Analyzer**: Potential bugs, memory issues, logic errors

### Quick Hygiene Commands

```bash
# Check project health
xcodebuild clean build -scheme QRCodeApp 2>&1 | xcsift -w

# Full test suite
xcodebuild test -scheme QRCodeApp 2>&1 | xcsift -w

# Analyze code
xcodebuild analyze -scheme QRCodeApp 2>&1 | xcsift -w
```

---

## grep or Search Text

### Using ast-grep for Code Search

**IMPORTANT**: Default to `ast-grep` for any code search requiring syntax or structure understanding.

### ast-grep Overview

- **Purpose**: Structural code search using Abstract Syntax Tree (AST)
- **Installation**: Already installed at `/opt/homebrew/bin/ast-grep`
- **Languages Supported**: Swift, and many others

### When to Use ast-grep

✅ **Use ast-grep for**:
- Finding function/method definitions
- Searching for class/struct declarations
- Locating protocol conformances
- Finding property declarations
- Complex syntax patterns
- Refactoring assistance

❌ **Use text search (grep) for**:
- Plain text strings explicitly requested
- Comments or documentation
- Simple literal text searches

### Swift-Specific ast-grep Patterns

```bash
# Find all struct definitions
ast-grep --lang swift -p 'struct $NAME { $$$ }'

# Find all class definitions
ast-grep --lang swift -p 'class $NAME { $$$ }'

# Find all function definitions
ast-grep --lang swift -p 'func $NAME($$$) { $$$ }'

# Find all SwiftUI View definitions
ast-grep --lang swift -p 'struct $NAME: View { $$$ }'

# Find all @State properties
ast-grep --lang swift -p '@State var $NAME'

# Find all @Published properties
ast-grep --lang swift -p '@Published var $NAME'

# Find all protocol conformances
ast-grep --lang swift -p 'extension $TYPE: $PROTOCOL { $$$ }'

# Find all import statements
ast-grep --lang swift -p 'import $MODULE'
```

### Useful ast-grep Flags

```bash
# Search in specific files
ast-grep --lang swift -p 'pattern' path/to/file.swift

# Show context lines
ast-grep --lang swift -p 'pattern' -C 3

# JSON output for parsing
ast-grep --lang swift -p 'pattern' --json

# Interactive mode
ast-grep --lang swift -p 'pattern' --interactive
```

### Example Searches for This Project

```bash
# Find all SwiftUI views
ast-grep --lang swift -p 'struct $NAME: View { $$$ }' QRCodeApp/

# Find all test functions
ast-grep --lang swift -p 'func test$NAME() throws { $$$ }' QRCodeAppTests/

# Find @main entry point
ast-grep --lang swift -p '@main struct $NAME: App { $$$ }' QRCodeApp/

# Find all @State variables
ast-grep --lang swift -p '@State private var $NAME' QRCodeApp/
```

---

## Apple Platforms Tips

### Essential Performance & Efficiency Guidelines

These tips are critical for building high-quality iOS/macOS applications.

#### 1. Profile Early and Often

- **Tool**: Instruments in Xcode 26
- **Focus Areas**: 
  - SwiftUI view performance
  - Foundation Model request latency
  - Memory allocations
  - Energy usage
- **Best Practice**: Identify bottlenecks before shipping

```bash
# Profile with Instruments
xcodebuild build -scheme QRCodeApp -configuration Release
# Then: Product > Profile in Xcode (Cmd+I)
```

#### 2. Optimize SwiftUI Views

**Key Areas**:
- Profile view trees to identify expensive computations
- Cache expensive computations using `@State`, `@StateObject`, or computed properties
- Minimize main thread usage
- Avoid repeated `body` computations that cause dropped frames

**Best Practices**:
```swift
// ❌ Bad: Expensive computation in body
struct ContentView: View {
    var body: some View {
        Text(expensiveCalculation())
    }
    
    func expensiveCalculation() -> String {
        // Heavy computation on every body evaluation
        return "Result"
    }
}

// ✅ Good: Cache expensive computation
struct ContentView: View {
    @State private var cachedResult: String = ""
    
    var body: some View {
        Text(cachedResult)
            .onAppear {
                cachedResult = expensiveCalculation()
            }
    }
}
```

#### 3. Streamline Foundation Model Requests

**Optimization Strategies**:
- Reduce context payloads - send only necessary data
- Remove redundant data from requests
- Keep request windows small for faster responses
- Batch requests when possible

#### 4. Memory and Algorithm Improvements

**Modern Swift Features**:
- Use `InlineArray` for small, fixed-size collections
- Use `Span` types for efficient memory access
- Replace custom loops with built-in methods like `first(where:)`
- Validate speedups with flame graphs in Instruments

```swift
// ✅ Use built-in methods
let firstMatch = items.first(where: { $0.matches(criteria) })

// ❌ Avoid custom loops
var firstMatch: Item?
for item in items {
    if item.matches(criteria) {
        firstMatch = item
        break
    }
}
```

#### 5. Accelerate App Launch

**Best Practices**:
- Defer non-critical work until after launch
- Move blocking operations off main thread:
  - Network requests
  - File I/O
  - Heavy calculations
- Load only essential data initially

```swift
@main
struct QRCodeAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Defer non-critical initialization
                    Task.detached(priority: .background) {
                        await performHeavyInitialization()
                    }
                }
        }
    }
}
```

#### 6. Minimize Energy Usage

**Strategies**:
- Use incremental updates instead of full reloads
- Fetch/display only what users need right now
- Implement pagination for large data sets
- Use background refresh judiciously
- Batch network requests

```swift
// ✅ Incremental updates
struct ContentView: View {
    @State private var visibleItems: [Item] = []
    
    var body: some View {
        List(visibleItems) { item in
            ItemRow(item: item)
                .onAppear {
                    loadMoreIfNeeded(item)
                }
        }
    }
}
```

#### 7. Benchmark and Document

**Requirements**:
- Benchmark all performance changes
- Document optimization decisions in code comments
- Use XCTest performance tests for regression tracking
- Compare before/after metrics

```swift
func testPerformanceExample() throws {
    measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
        // Code to benchmark
        performCriticalOperation()
    }
}
```

### Performance Testing Commands

```bash
# Run performance tests
xcodebuild test -scheme QRCodeApp -only-testing:QRCodeAppTests/testPerformanceExample 2>&1 | xcsift -w

# Profile build in Release mode
xcodebuild build -scheme QRCodeApp -configuration Release 2>&1 | xcsift -w
```

---

## Quick Reference

### Essential Commands

```bash
# Build
xcodebuild build -scheme QRCodeApp 2>&1 | xcsift -w

# Test
xcodebuild test -scheme QRCodeApp 2>&1 | xcsift -w

# Clean
xcodebuild clean -scheme QRCodeApp

# Search code structure
ast-grep --lang swift -p 'pattern' QRCodeApp/

# Text search
grep -r "pattern" QRCodeApp/
```

### Project Info

- **Scheme**: QRCodeApp
- **Minimum Xcode**: 26.1.1
- **Build System**: Xcode Build System
- **Testing**: XCTest framework
- **Tools Available**: xcsift, ast-grep

---

## Agent Workflow

1. **Before Changes**:
   ```bash
   xcodebuild build -scheme QRCodeApp 2>&1 | xcsift -w
   xcodebuild test -scheme QRCodeApp 2>&1 | xcsift -w
   ```

2. **During Development**:
   - Use `ast-grep` for code structure searches
   - Write/update tests alongside code changes
   - Build incrementally to catch errors early

3. **After Changes**:
   ```bash
   xcodebuild build -scheme QRCodeApp 2>&1 | xcsift -w
   xcodebuild test -scheme QRCodeApp 2>&1 | xcsift -w
   ```

4. **Before Completion**:
   - ✅ All builds succeed
   - ✅ All tests pass
   - ✅ No warnings remain
   - ✅ Code hygiene maintained

---

*Last Updated: 22 November 2025*
