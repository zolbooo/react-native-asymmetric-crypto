package com.github.zolbooo.asymmetriccrypto

import com.facebook.react.bridge.*

class AsymmetricCryptoModule : ReactContextBaseJavaModule() {
    override fun getName(): String {
        return "RNAsymmetricCrypto"
    }

    @ReactMethod
    fun isHardwareSecuritySupported(promise: Promise) {
        TODO("Not yet implemented")
    }

    @ReactMethod
    fun getAvailableBiometryType(promise: Promise) {
        TODO("Not yet implemented")
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
