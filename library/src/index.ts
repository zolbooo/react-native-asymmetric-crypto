import type { Spec as RNAsymmetricCryptoModule } from "./NativeRNAsymmetricCrypto";

const isTurboModuleEnabled = (global as any).__turboModuleProxy != null;

const RNAsymmetricCrypto: RNAsymmetricCryptoModule = isTurboModuleEnabled
  ? require("./NativeRNAsymmetricCrypto").default
  : require("./RNAsymmetricCrypto").default;

export default RNAsymmetricCrypto;
