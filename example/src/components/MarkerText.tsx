import { StyleSheet, View, Text } from 'react-native';
import { MapMarker, type MapMarkerProps } from '@lugg/maps';

interface MarkerTextProps extends MapMarkerProps {
  text: string;
  color?: string;
}

export function MarkerText({
  text,
  color = '#EA4335',
  anchor = { x: 0.5, y: 0.5 },
  ...rest
}: MarkerTextProps) {
  return (
    <MapMarker anchor={anchor} {...rest}>
      <View style={[styles.container, { backgroundColor: color }]}>
        <Text style={styles.text}>{text}</Text>
      </View>
    </MapMarker>
  );
}

const styles = StyleSheet.create({
  container: {
    borderRadius: 16,
    width: 32,
    height: 32,
    justifyContent: 'center',
    alignItems: 'center',
  },
  text: {
    color: 'white',
    fontWeight: 'bold',
    fontSize: 14,
  },
});
