---
paths:
  - "src/**/*.rs"
  - "tests/**/*.rs"
---

# Rust Conventions

## Error Handling

- Define a crate-level `Error` enum with `thiserror`
- All public functions return `Result<T, Error>`
- Never `unwrap()` or `expect()` in library/production code
- Use `anyhow` in binaries and tests, `thiserror` in libraries
- `?` operator for propagation, `map_err` to add context

## Ownership & Borrowing

- Prefer `&str` over `String` in function parameters
- Prefer `&[T]` over `Vec<T>` in function parameters
- Clone only when ownership transfer is genuinely needed
- Use `Cow<'_, str>` when a function might or might not allocate

## Patterns

- Builder pattern for structs with many optional fields
- `impl From<X> for Y` for type conversions
- `#[derive(Debug, Clone, PartialEq)]` on all public types
- `#[derive(Serialize, Deserialize)]` on all data transfer types
- Newtype pattern for domain types: `struct UserId(Uuid)`

## Testing

- Unit tests in `#[cfg(test)] mod tests` at bottom of each file
- Integration tests in `tests/` directory
- Use `#[test]` for sync, `#[tokio::test]` for async
- Property-based testing with `proptest` for complex logic

## Documentation

- `///` doc comments on all public items
- Include `# Examples` section with runnable code blocks
- `//!` module-level docs explaining the module's purpose
