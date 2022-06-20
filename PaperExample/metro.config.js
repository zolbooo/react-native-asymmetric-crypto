const path = require('path');

// Use custom root so Metro can resolve a symlink to our library
const root = path.resolve(__dirname, '..');

module.exports = {
  projectRoot: __dirname,
  watchFolders: [root],
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: true,
      },
    }),
  },
};
