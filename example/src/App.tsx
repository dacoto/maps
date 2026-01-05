import { useRef, useState } from 'react';
import { StyleSheet, View, Platform } from 'react-native';
import { MapView, MapMarker, type MapProvider } from '@lugg/maps';
import { TrueSheet } from '@lodev09/react-native-true-sheet';

import { Button, MarkerIcon, MarkerText, MarkerImage } from './components';

type MarkerType = 'basic' | 'icon' | 'text' | 'image' | 'custom';

interface Marker {
  id: string;
  name: string;
  coordinate: { latitude: number; longitude: number };
  type: MarkerType;
  title?: string;
  description?: string;
  anchor?: { x: number; y: number };
  text?: string;
  color?: string;
  imageUrl?: string;
}

const MARKER_COLORS = ['#EA4335', '#4285F4', '#34A853', '#FBBC05', '#9C27B0', '#FF5722'];
const AVATAR_URLS = [
  'https://i.pravatar.cc/100?img=1',
  'https://i.pravatar.cc/100?img=2',
  'https://i.pravatar.cc/100?img=3',
  'https://i.pravatar.cc/100?img=4',
  'https://i.pravatar.cc/100?img=5',
];

const INITIAL_MARKERS: Marker[] = [
  {
    id: '1',
    name: 'sf-marker',
    coordinate: { latitude: 37.78, longitude: -122.43 },
    type: 'basic',
    title: 'San Francisco',
    description: 'The Golden Gate City',
  },
  {
    id: '2',
    name: 'marker-2',
    coordinate: { latitude: 37.785, longitude: -122.42 },
    type: 'basic',
    anchor: { x: 0.5, y: 1 },
  },
  {
    id: '3',
    name: 'marker-3',
    coordinate: { latitude: 37.775, longitude: -122.443 },
    type: 'basic',
  },
  {
    id: '4',
    name: 'marker-4',
    coordinate: { latitude: 37.775, longitude: -122.44 },
    type: 'basic',
    anchor: { x: 0.5, y: 1 },
  },
  {
    id: '5',
    name: 'marker-5',
    coordinate: { latitude: 37.79, longitude: -122.435 },
    type: 'basic',
    anchor: { x: 0.5, y: 1 },
  },
];

export default function App() {
  const sheetRef = useRef<TrueSheet>(null);
  const [provider, setProvider] = useState<MapProvider>('google');
  const [showMap, setShowMap] = useState(true);
  const [markers, setMarkers] = useState(INITIAL_MARKERS);

  const toggleProvider = () => {
    setProvider((prev) => (prev === 'google' ? 'apple' : 'google'));
  };

  const removeRandomMarker = () => {
    if (markers.length === 0) return;
    const randomIndex = Math.floor(Math.random() * markers.length);
    setMarkers((prev) => prev.filter((_, index) => index !== randomIndex));
  };

  const addRandomMarker = () => {
    const types: MarkerType[] = ['basic', 'icon', 'text', 'image', 'custom'];
    const randomType = types[Math.floor(Math.random() * types.length)];
    const randomColor = MARKER_COLORS[Math.floor(Math.random() * MARKER_COLORS.length)];
    const randomAvatar = AVATAR_URLS[Math.floor(Math.random() * AVATAR_URLS.length)];
    const randomLetter = String.fromCharCode(65 + Math.floor(Math.random() * 26));

    // Random coordinate around San Francisco
    const latitude = 37.77 + Math.random() * 0.03;
    const longitude = -122.45 + Math.random() * 0.05;

    const id = Date.now().toString();
    const newMarker: Marker = {
      id,
      name: `marker-${id}`,
      coordinate: { latitude, longitude },
      type: randomType,
      anchor: { x: 0.5, y: randomType === 'icon' ? 1 : 0.5 },
      text: randomLetter,
      color: randomColor,
      imageUrl: randomAvatar,
    };

    setMarkers((prev) => [...prev, newMarker]);
  };

  return (
    <View style={styles.container}>
      {showMap && (
        <MapView
          style={styles.map}
          mapId="6939261d95ee48fd57332474"
          provider={provider}
          initialCoordinate={{ latitude: 37.78, longitude: -122.43 }}
          initialZoom={14}
        >
          {markers.map((marker) => {
            switch (marker.type) {
              case 'icon':
                return (
                  <MarkerIcon
                    key={marker.id}
                    name={marker.name}
                    coordinate={marker.coordinate}
                  />
                );
              case 'text':
                return (
                  <MarkerText
                    key={marker.id}
                    name={marker.name}
                    coordinate={marker.coordinate}
                    text={marker.text ?? 'X'}
                    color={marker.color}
                  />
                );
              case 'image':
                return (
                  <MarkerImage
                    key={marker.id}
                    name={marker.name}
                    coordinate={marker.coordinate}
                    source={{ uri: marker.imageUrl }}
                  />
                );
              case 'custom':
                return (
                  <MapMarker
                    key={marker.id}
                    name={marker.name}
                    coordinate={marker.coordinate}
                    anchor={marker.anchor}
                  >
                    <View style={{ backgroundColor: marker.color, height: 40, width: 40, borderRadius: 8 }} />
                  </MapMarker>
                );
              default:
                return (
                  <MapMarker
                    key={marker.id}
                    name={marker.name}
                    coordinate={marker.coordinate}
                    title={marker.title}
                    description={marker.description}
                    anchor={marker.anchor}
                  />
                );
            }
          })}
          <MarkerIcon
            name="marker-icon"
            coordinate={{ latitude: 37.788, longitude: -122.41 }}
          />
          <MarkerText
            name="marker-text-a"
            coordinate={{ latitude: 37.772, longitude: -122.425 }}
            text="A"
          />
          <MarkerText
            name="marker-text-b"
            coordinate={{ latitude: 37.795, longitude: -122.42 }}
            text="B"
            color="#4285F4"
          />
          <MarkerImage
            name="marker-image"
            coordinate={{ latitude: 37.782, longitude: -122.415 }}
            source={{ uri: 'https://i.pravatar.cc/100' }}
          />
          <MapMarker
            name="marker-simple"
            coordinate={{ latitude: 37.782, longitude: -122.42 }}
            anchor={{ x: 0.5, y: 1 }}
          >
            <View style={{ backgroundColor: 'red', height: 40, width: 40 }} />
          </MapMarker>
          <View style={{ zIndex: 10, backgroundColor: 'blue', height: 40, width: 40 }} />
        </MapView>
      )}

      <TrueSheet
        ref={sheetRef}
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
          <Button
            title={showMap ? 'Hide Map' : 'Show Map'}
            onPress={() => setShowMap((prev) => !prev)}
          />
          <Button
            title={
              provider === 'google'
                ? 'Switch to Apple Maps'
                : 'Switch to Google Maps'
            }
            disabled={Platform.OS === 'android'}
            onPress={toggleProvider}
          />
        </View>
      </TrueSheet>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  map: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sheetContent: {
    padding: 16,
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
});
