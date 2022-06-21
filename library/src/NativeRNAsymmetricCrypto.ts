import type { TurboModule } from "react-native";
import { TurboModuleRegistry } from "react-native";

export type BiometryType = "FaceID" | "TouchID" | "Generic";

export interface Spec extends TurboModule {
  getAvailableBiometryType(): Promise<
    | {
        available: false;
        error?: string;
      }
    | { available: true; biometryType: BiometryType }
  >;
  isHardwareSecuritySupported(): Promise<boolean>;

  keyExists(alias: string): Promise<{ exists: boolean; error?: string }>;
  createKey(options: {
    alias: string;
    securityLevel: string;
  }): Promise<{ publicKey: string }>;
  removeKey(alias: string): Promise<boolean>;

  sign(options: {
    alias: string;
    dataBase64: string;
    prompt?: string;
  }): Promise<string>;
}

export default TurboModuleRegistry.get<Spec>("RNAsymmetricCrypto");
