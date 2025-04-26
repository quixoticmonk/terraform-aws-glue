# Schema Registry Dependency Example

This example demonstrates how to manage dependencies between Glue Schema and Glue Registry resources.

## Usage

```bash
terraform init
terraform apply
```

## Features Demonstrated

1. Creating a Glue Registry and Schema together with proper dependency management
2. Creating a Schema that uses an existing Registry (created by another module instance)

## Architecture

This example creates:

1. First module instance:
   - A Glue Registry
   - A Glue Schema that uses the created Registry

2. Second module instance:
   - A Glue Schema that references the Registry created by the first module

## Notes

- The module automatically handles the dependency between Schema and Registry when both are created within the same module instance
- When using an existing Registry, you must provide the `schema_registry_name` variable
- The `depends_on` meta-argument ensures the second module runs after the first one is complete
