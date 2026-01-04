import { useState } from 'react';
import { StyleSheet, View, Text, Image, TouchableOpacity, Platform } from 'react-native';
import { MapView, MapMarker, type MapProvider } from '@lugg/maps';
import Svg, { Path, Circle } from 'react-native-svg';

function MarkerIcon() {
  return (
    <Svg width={32} height={40} viewBox="0 0 32 40" fill="none">
      <Path
        d="M16 0C7.164 0 0 7.164 0 16c0 12 16 24 16 24s16-12 16-24c0-8.836-7.164-16-16-16z"
        fill="#EA4335"
      />
      <Circle cx={16} cy={16} r={6} fill="white" />
    </Svg>
  );
}

export default function App() {
  const [provider, setProvider] = useState<MapProvider>('google');

  const toggleProvider = () => {
    setProvider((prev) => (prev === 'google' ? 'apple' : 'google'));
  };

  return (
    <View style={styles.container}>
      <MapView
        style={styles.map}
        provider={provider}
        initialCoordinate={{ latitude: 37.78, longitude: -122.43 }}
        initialZoom={14}
      >
        <MapMarker
          coordinate={{ latitude: 37.78, longitude: -122.43 }}
          title="San Francisco"
          description="The Golden Gate City"
        />
        <MapMarker
          coordinate={{ latitude: 37.785, longitude: -122.42 }}
          anchor={{ x: 0.5, y: 1 }}
        >
          <View style={styles.customMarker}>
            <Text style={styles.customMarkerText}>Oakland</Text>
          </View>
        </MapMarker>

        <MapMarker coordinate={{ latitude: 37.775, longitude: -122.44 }} />
        <MapMarker
          coordinate={{ latitude: 37.775, longitude: -122.44 }}
          anchor={{ x: 0.5, y: 1 }}
        >
          <Image
            source={{
              uri: 'https://maps.google.com/mapfiles/ms/icons/blue-dot.png',
            }}
            style={styles.markerImage}
          />
        </MapMarker>
        <MapMarker
          coordinate={{ latitude: 37.79, longitude: -122.435 }}
          anchor={{ x: 0.5, y: 1 }}
        >
          <MarkerIcon />
        </MapMarker>
      </MapView>

      {Platform.OS === 'ios' && (
        <TouchableOpacity style={styles.toggleButton} onPress={toggleProvider}>
          <Text style={styles.toggleButtonText}>
            {provider === 'google' ? 'Google Maps' : 'Apple Maps'}
          </Text>
        </TouchableOpacity>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  map: {
    flex: 1,
  },
  customMarker: {
    backgroundColor: '#4285F4',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    width: 120,
    alignItems: 'center',
  },
  customMarkerText: {
    color: 'white',
    fontSize: 12,
    fontWeight: 'bold',
  },
  markerImage: {
    width: 80,
    height: 80,
  },
  toggleButton: {
    position: 'absolute',
    top: 60,
    right: 16,
    backgroundColor: '#007AFF',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
  },
  toggleButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
});
