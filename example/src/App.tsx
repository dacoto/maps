import { StyleSheet } from 'react-native';
import { MapView, MapMarker } from '@lugg/maps';

export default function App() {
  return (
    <MapView
      style={styles.map}
      provider="google"
      initialRegion={{
        latitude: 37.7749,
        longitude: -122.4194,
        latitudeDelta: 0.0922,
        longitudeDelta: 0.0421,
      }}
    >
      <MapMarker
        coordinate={{ latitude: 37.7749, longitude: -122.4194 }}
        title="San Francisco"
        description="The Golden Gate City"
      />
      <MapMarker
        coordinate={{ latitude: 37.8044, longitude: -122.2712 }}
        title="Oakland"
        description="Across the Bay"
      />
      <MapMarker
        coordinate={{ latitude: 37.8716, longitude: -122.2727 }}
        title="Berkeley"
        description="Home of UC Berkeley"
      />
    </MapView>
  );
}

const styles = StyleSheet.create({
  map: {
    flex: 1,
  },
});
