# Agent Instructions

## General Rules

1. YOU MUST NOT do builds unless you are told to.
2. YOU MUST NOT commit changes yourself until I explicitly tell you to.
3. YOU MUST NOT create summary documents unless you are told to.
4. YOU MUST NOT add code comments that are obvious.
5. Be extremely concise, sacrifice grammar for concision.
6. Read and understand relevant files before proposing code edits.
7. If code does not work, revert it first before proceeding with another edit.

## Over-Engineering Prevention

- Only make changes directly requested or clearly necessary
- Don't add features, refactoring, or "improvements" beyond what's asked
- Don't add docstrings, comments, or type annotations to code you didn't change
- Don't add error handling, fallbacks, or validation for scenarios that can't happen
- Trust internal code and framework guarantees
- Only validate at system boundaries (user input, external APIs)
- Don't create helpers, utilities, or abstractions for one-time operations
- Don't design for hypothetical future requirements

## Project Overview

React Native Fabric (New Architecture) maps library for iOS and Android.

- **Fabric** - No bridge, direct C++ communication
- **Codegen** - Auto-generates native interfaces from TypeScript specs

### Creating a Pull Request

When creating a PR, use the template from `.github/PULL_REQUEST_TEMPLATE.md`:

1. **Summary** - Describe what the PR does and why
2. **Type of Change** - Select one: Bug fix, New feature, Breaking change, or Documentation update
3. **Test Plan** - Explain how the changes were tested
4. **Screenshots / Videos** - Include if applicable
5. **Checklist** - Mark platforms tested (iOS, Android, Web) and documentation updates
