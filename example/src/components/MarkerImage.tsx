import { StyleSheet, Image, type ImageSourcePropType } from 'react-native';
import { MapMarker, type MapMarkerProps } from '@lugg/maps';

interface MarkerImageProps extends MapMarkerProps {
  source: ImageSourcePropType;
  size?: number;
}

export function MarkerImage({
  source,
  size = 40,
  anchor = { x: 0.5, y: 0.5 },
  ...rest
}: MarkerImageProps) {
  return (
    <MapMarker anchor={anchor} {...rest}>
      <Image
        source={source}
        style={[
          styles.image,
          { width: size, height: size, borderRadius: size / 2 },
        ]}
      />
    </MapMarker>
  );
}

const styles = StyleSheet.create({
  image: {
    borderWidth: 2,
    borderColor: 'white',
  },
});
