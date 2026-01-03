import { codegenNativeComponent } from 'react-native';
import type { ViewProps, HostComponent } from 'react-native';

export interface Region {
  latitude: number;
  longitude: number;
  latitudeDelta: number;
  longitudeDelta: number;
}

export interface NativeProps extends ViewProps {
  initialRegion?: Region;
  zoomEnabled?: boolean;
  scrollEnabled?: boolean;
  rotateEnabled?: boolean;
  pitchEnabled?: boolean;
}

export default codegenNativeComponent<NativeProps>(
  'MapView'
) as HostComponent<NativeProps>;
