import { codegenNativeComponent, codegenNativeCommands } from 'react-native';
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
  initialCoordinate?: Coordinate;
  initialZoom?: WithDefault<Double, 10>;
  zoomEnabled?: WithDefault<boolean, true>;
  scrollEnabled?: WithDefault<boolean, true>;
  rotateEnabled?: WithDefault<boolean, true>;
  pitchEnabled?: WithDefault<boolean, true>;
}

type ComponentType = HostComponent<NativeProps>;

interface NativeCommands {
  moveCamera: (
    viewRef: React.ElementRef<ComponentType>,
    latitude: Double,
    longitude: Double,
    zoom: Double,
    duration: Double
  ) => void;
  fitCoordinates: (
    viewRef: React.ElementRef<ComponentType>,
    coordinates: Coordinate[],
    padding: Double,
    duration: Double
  ) => void;
}

export const Commands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['moveCamera', 'fitCoordinates'],
});

export default codegenNativeComponent<NativeProps>(
  'AppleMapView'
) as ComponentType;
