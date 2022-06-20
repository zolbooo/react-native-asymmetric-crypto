const path = require('path');

module.exports = {
  getProjectRoots() {
    return [path.resolve(__dirname), path.resolve(__dirname, '../')];
  },
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: true,
      },
    }),
  },
};
