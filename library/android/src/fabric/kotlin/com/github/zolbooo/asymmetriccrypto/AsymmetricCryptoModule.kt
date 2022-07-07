package com.github.zolbooo.asymmetriccrypto

import com.facebook.react.bridge.*

class AsymmetricCryptoModule(reactContext: ReactApplicationContext?) :
    NativeRNAsymmetricCryptoSpec(reactContext) {
    override fun getName(): String {
        return "RNAsymmetricCrypto"
    }

    override fun getAvailableBiometryType(promise: Promise?) {
        TODO("Not yet implemented")
    }

    override fun isHardwareSecuritySupported(promise: Promise?) {
        TODO("Not yet implemented")
    }

    override fun keyExists(alias: String?, promise: Promise?) {
        TODO("Not yet implemented")
    }

    override fun createKey(options: ReadableMap?, promise: Promise?) {
        TODO("Not yet implemented")
    }

    override fun removeKey(alias: String?, promise: Promise?) {
        TODO("Not yet implemented")
    }

    override fun sign(options: ReadableMap?, promise: Promise?) {
        TODO("Not yet implemented")
    }
}
