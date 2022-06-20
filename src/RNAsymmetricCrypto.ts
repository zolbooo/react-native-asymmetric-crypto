import { NativeModules } from "react-native";

import type { Spec } from "./NativeRNAsymmetricCrypto";

const RNAsymmetricCryptoModule = NativeModules.RNAsymmetricCrypto;

const RNAsymmetricCrypto: Spec = new RNAsymmetricCryptoModule();
export default RNAsymmetricCrypto;
