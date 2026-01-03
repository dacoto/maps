import { StyleSheet } from 'react-native';
import { MapView } from '@lugg/maps';

export default function App() {
  return (
    <MapView
      style={styles.map}
      initialRegion={{
        latitude: 37.7749,
        longitude: -122.4194,
        latitudeDelta: 0.0922,
        longitudeDelta: 0.0421,
      }}
    />
  );
}

const styles = StyleSheet.create({
  map: {
    flex: 1,
  },
});
