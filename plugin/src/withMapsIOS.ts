import { type ConfigPlugin, withInfoPlist } from '@expo/config-plugins';

export interface MapsIOSPluginProps {
  apiKey?: string;
}

export const withMapsIOS: ConfigPlugin<MapsIOSPluginProps> = (
  config,
  { apiKey }
) => {
  if (!apiKey) {
    return config;
  }

  return withInfoPlist(config, (c) => {
    c.modResults.GMSApiKey = apiKey;
    return c;
  });
};
