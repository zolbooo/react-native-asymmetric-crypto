package com.github.zolbooo.asymmetriccrypto

import com.facebook.react.bridge.*

class AsymmetricCryptoModule : ReactContextBaseJavaModule() {
    override fun getName(): String {
        return "RNAsymmetricCrypto"
    }

    @ReactMethod
    fun getAvailableBiometryType(promise: Promise) {
        promise.resolve(
            Arguments.createMap().apply {
                putBoolean(
                    "available",
                    Biometrics.isBiometryAvailable(reactApplicationContext),
                )
                putString("biometryType", "Generic")
            }
        )
    }

    @ReactMethod
    fun keyExists(alias: String?, promise: Promise) {
        TODO("Not yet implemented")
    }

    @ReactMethod
    fun createKey(options: ReadableMap?, promise: Promise) {
        TODO("Not yet implemented")
    }

    @ReactMethod
    fun removeKey(alias: String?, promise: Promise) {
        TODO("Not yet implemented")
    }

    @ReactMethod
    fun sign(options: ReadableMap?, promise: Promise) {
        TODO("Not yet implemented")
    }
}
