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
}

export default TurboModuleRegistry.get<Spec>("RNAsymmetricCrypto");
