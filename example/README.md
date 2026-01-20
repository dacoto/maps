# Examples

This directory contains example apps demonstrating `@lugg/maps`.

## Structure

```
example/
├── bare/     # Bare React Native (react-native-community/cli)
├── expo/     # Expo managed workflow
└── shared/   # Shared components used by both examples
```

## Running

From the repo root:

```sh
# Install dependencies
yarn

# Run bare example
yarn bare ios
yarn bare android

# Run expo example
yarn expo ios
yarn expo android
```

## Shared Components

The `shared/` directory contains reusable components and utilities used by both example apps. This ensures consistent behavior across different React Native environments.
