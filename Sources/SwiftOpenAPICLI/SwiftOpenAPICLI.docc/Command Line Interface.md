# Command Line Interface

Run your validation with a simple command line tool.

## Overview

SwiftOpenAPICLI is a command line tool available for macOS, Linux and Windows systems. 
It is a simple executable that runs in a shell, terminal or PowerShell environment. 
The validation includes OAS 3.0 and JSONSchema validation with the limitations for OAS 3.0.

The tool provides basic functionality for:
- Loading and parsing OpenAPI specifications
- Validating OpenAPI documents against the specification rules
- Displaying basic information about OpenAPI files

## Usage Examples

### Basic Usage

Display basic information about an OpenAPI specification:

```bash
$ swift run swiftopenapicli path/to/your/openapi.yaml
OpenAPI: 3.1.0
Title: My API
```

### Version Information

Check the installed version of the CLI:

```bash
$ swift run swiftopenapicli path/to/openapi.yaml --version
0.1.0
```

### Validation

Validate an OpenAPI specification against the rules:

```bash
$ swift run swiftopenapicli path/to/openapi.yaml --validate
Validation: OK
```

Or with validation errors:

```bash
$ swift run swiftopenapicli path/to/invalid-openapi.yaml --validate
The Responses Object MUST contain at least one response code, and it SHOULD be the response for a successful operation call.
```

## Error Handling

The CLI returns appropriate exit codes:
- `0` for success
- `1` for errors

### Missing Argument

```bash
$ swift run swiftopenapicli
Error: Usage: SwiftOpenAPICLI <path-to-openapi.(yaml|yml|json)>
```

### Invalid Option

```bash
$ swift run swiftopenapicli openapi.yaml --unknown
Error: Invalid option: --unknown
```

### File Not Found

```bash
$ swift run swiftopenapicli nonexistent.yaml
Error: File not found: nonexistent.yaml
```

## Testing the CLI

The CLI functionality can be tested programmatically using the `SwiftOpenAPICLIApp` class:

```swift
import SwiftOpenAPICLI

let app = SwiftOpenAPICLIApp()
var stdout = StringTextOutputStream()
var stderr = StringTextOutputStream()
let exitCode = await app.run(
    args: ["SwiftOpenAPICLI", "path/to/spec.yaml"], 
    stdout: &stdout, 
    stderr: &stderr
)
```

## Topics

### Core Functionality

- ``SwiftOpenAPICLIApp``
- ``SwiftOpenAPICLIApp/run(args:stdout:stderr:)``

### Error Handling

- ``SwiftOpenAPICLIError``
