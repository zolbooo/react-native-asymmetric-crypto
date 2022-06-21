import type { Spec as RNAsymmetricCryptoModule } from "./NativeRNAsymmetricCrypto";

const isTurboModuleEnabled = (global as any).__turboModuleProxy != null;

export enum KeySecurityLevel {
  NONE = "none",
  PASSWORD = "password",
  BIOMETRICS = "biometrics",
}

const RNAsymmetricCrypto: Omit<RNAsymmetricCryptoModule, "createKey"> & {
  createKey(options: {
    alias: string;
    securityLevel: KeySecurityLevel;
  }): Promise<
    | { success: true }
    | {
        success: false;
        error?: string;
      }
  >;
} = isTurboModuleEnabled
  ? require("./NativeRNAsymmetricCrypto").default
  : require("./RNAsymmetricCrypto").default;

export default RNAsymmetricCrypto;
