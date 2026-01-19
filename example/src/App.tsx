import { useRef, useState } from 'react';
import { StyleSheet, View, Platform } from 'react-native';
import { MapView, type MapProvider } from '@lugg/maps';
import { TrueSheet } from '@lodev09/react-native-true-sheet';

import { Button, Map } from './components';
import { randomFrom, randomLetter } from './utils';
import {
  MARKER_COLORS,
  AVATAR_URLS,
  MARKER_TYPES,
  INITIAL_MARKERS,
} from './markers';

export default function App() {
  const mapRef = useRef<MapView>(null);
  const [provider, setProvider] = useState<MapProvider>('google');
  const [showMap, setShowMap] = useState(true);
  const [markers, setMarkers] = useState(INITIAL_MARKERS);

  const addRandomMarker = () => {
    const type = randomFrom(MARKER_TYPES);
    const id = Date.now().toString();

    setMarkers((prev) => [
      ...prev,
      {
        id,
        name: `marker-${id}`,
        coordinate: {
          latitude: 37.77 + Math.random() * 0.03,
          longitude: -122.45 + Math.random() * 0.05,
        },
        type,
        anchor: { x: 0.5, y: type === 'icon' ? 1 : 0.5 },
        text: randomLetter(),
        color: randomFrom(MARKER_COLORS),
        imageUrl: randomFrom(AVATAR_URLS),
      },
    ]);
  };

  const removeRandomMarker = () => {
    if (markers.length === 0) return;
    setMarkers((prev) =>
      prev.filter((_, i) => i !== Math.floor(Math.random() * prev.length))
    );
  };

  const moveToRandomMarker = () => {
    if (markers.length === 0) return;
    mapRef.current?.moveCamera({
      coordinate: randomFrom(markers).coordinate,
      zoom: 12 + Math.random() * 4,
    });
  };

  return (
    <View style={styles.container}>
      {showMap && <Map ref={mapRef} provider={provider} markers={markers} />}

      <TrueSheet
        detents={['auto']}
        dimmed={false}
        initialDetentIndex={0}
        initialDetentAnimated={false}
        dismissible={false}
        grabber={false}
      >
        <View style={styles.sheetContent}>
          <Button title="Add Marker" onPress={addRandomMarker} />
          <Button
            title={`Remove Marker (${markers.length})`}
            onPress={removeRandomMarker}
            disabled={markers.length === 0}
          />
          <Button title="Move Camera" onPress={moveToRandomMarker} />
          <Button
            title={showMap ? 'Hide Map' : 'Show Map'}
            onPress={() => setShowMap((prev) => !prev)}
          />
          <Button
            title={provider === 'google' ? 'Apple Maps' : 'Google Maps'}
            disabled={Platform.OS === 'android'}
            onPress={() =>
              setProvider((p) => (p === 'google' ? 'apple' : 'google'))
            }
          />
        </View>
      </TrueSheet>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  sheetContent: {
    padding: 16,
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
});
