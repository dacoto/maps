import { codegenNativeComponent } from 'react-native';
import type { ViewProps, HostComponent } from 'react-native';
import type { Double, WithDefault } from 'react-native/Libraries/Types/CodegenTypes';

export interface Region {
  latitude: Double;
  longitude: Double;
  latitudeDelta: Double;
  longitudeDelta: Double;
}

export interface NativeProps extends ViewProps {
  initialRegion?: Region;
  zoomEnabled?: WithDefault<boolean, true>;
  scrollEnabled?: WithDefault<boolean, true>;
  rotateEnabled?: WithDefault<boolean, true>;
  pitchEnabled?: WithDefault<boolean, true>;
}

export default codegenNativeComponent<NativeProps>(
  'GoogleMapView'
) as HostComponent<NativeProps>;
