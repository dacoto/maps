import { createContext, useContext } from 'react';

export const MapIdContext = createContext<string | null>(null);

export const useMapId = () => useContext(MapIdContext);
