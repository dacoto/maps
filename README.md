# @lugg/maps

React Native Fabric maps library for iOS and Android using Google Maps.

## Installation

```sh
npm install @lugg/maps
```

### iOS Setup

Add your Google Maps API key to `AppDelegate.swift`:

```swift
import GoogleMaps

// In application(_:didFinishLaunchingWithOptions:)
GMSServices.provideAPIKey("YOUR_API_KEY")
```

### Android Setup

Add your Google Maps API key to `AndroidManifest.xml`:

```xml
<application>
  <meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY" />
</application>
```

## Usage

```tsx
import { MapView } from '@lugg/maps';

<MapView
  style={{ flex: 1 }}
  initialRegion={{
    latitude: 37.7749,
    longitude: -122.4194,
    latitudeDelta: 0.0922,
    longitudeDelta: 0.0421,
  }}
  zoomEnabled={true}
  scrollEnabled={true}
  rotateEnabled={true}
  pitchEnabled={true}
/>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `initialRegion` | `Region` | - | Initial map region |
| `zoomEnabled` | `boolean` | `true` | Enable zoom gestures |
| `scrollEnabled` | `boolean` | `true` | Enable scroll gestures |
| `rotateEnabled` | `boolean` | `true` | Enable rotate gestures |
| `pitchEnabled` | `boolean` | `true` | Enable pitch/tilt gestures |

## Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## License

MIT
