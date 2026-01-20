const path = require('path');
const { getDefaultConfig } = require('expo/metro-config');
const { withMetroConfig } = require('react-native-monorepo-config');

const root = path.resolve(__dirname, '../..');

const config = withMetroConfig(getDefaultConfig(__dirname), {
  root,
  dirname: __dirname,
});

config.resolver.extraNodeModules = {
  ...config.resolver.extraNodeModules,
  'react-native': path.resolve(__dirname, 'node_modules/react-native'),
  'react': path.resolve(__dirname, 'node_modules/react'),
  'react-native-reanimated': path.resolve(
    __dirname,
    'node_modules/react-native-reanimated'
  ),
  'react-native-worklets': path.resolve(
    __dirname,
    'node_modules/react-native-worklets'
  ),
};

module.exports = config;
