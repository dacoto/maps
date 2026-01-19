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
  mapId?: WithDefault<string, 'DEMO_MAP_ID'>;
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
}

export const Commands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['moveCamera'],
});

export default codegenNativeComponent<NativeProps>(
  'GoogleMapView'
) as ComponentType;
