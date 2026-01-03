import { codegenNativeComponent } from 'react-native';
import type { ViewProps, HostComponent } from 'react-native';
import type { Double } from 'react-native/Libraries/Types/CodegenTypes';

export interface Coordinate {
  latitude: Double;
  longitude: Double;
}

export interface NativeProps extends ViewProps {
  coordinate: Coordinate;
  title?: string;
  description?: string;
}

export default codegenNativeComponent<NativeProps>(
  'MapMarkerView'
) as HostComponent<NativeProps>;
