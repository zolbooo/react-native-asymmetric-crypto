const isTurboModuleEnabled = (global as any).__turboModuleProxy != null;

const RNAsymmetricCrypto = isTurboModuleEnabled
  ? require("./NativeRNAsymmetricCrypto").default
  : require("./RNAsymmetricCrypto").default;

export default RNAsymmetricCrypto;
