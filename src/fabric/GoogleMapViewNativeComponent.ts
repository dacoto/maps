import { codegenNativeComponent } from 'react-native';
import type { ViewProps, HostComponent } from 'react-native';
import type {
  Double,
  WithDefault,
} from 'react-native/Libraries/Types/CodegenTypes';

export interface Coordinate {
  latitude: Double;
  longitude: Double;
}

export interface NativeProps extends ViewProps {
  mapId?: WithDefault<string, 'DEMO_MAP_ID'>;
  initialCoordinate?: Coordinate;
  initialZoom?: WithDefault<Double, 10>;
  zoomEnabled?: WithDefault<boolean, true>;
  scrollEnabled?: WithDefault<boolean, true>;
  rotateEnabled?: WithDefault<boolean, true>;
  pitchEnabled?: WithDefault<boolean, true>;
}

export default codegenNativeComponent<NativeProps>(
  'GoogleMapView'
) as HostComponent<NativeProps>;
