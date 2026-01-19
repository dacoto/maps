import { codegenNativeComponent } from 'react-native';
import type { ViewProps, HostComponent, ColorValue } from 'react-native';
import type { Double } from 'react-native/Libraries/Types/CodegenTypes';

export interface Coordinate {
  latitude: Double;
  longitude: Double;
}

export interface NativeProps extends ViewProps {
  coordinates: ReadonlyArray<Coordinate>;
  strokeColor?: ColorValue;
  strokeWidth?: Double;
}

export default codegenNativeComponent<NativeProps>(
  'PolylineView'
) as HostComponent<NativeProps>;
