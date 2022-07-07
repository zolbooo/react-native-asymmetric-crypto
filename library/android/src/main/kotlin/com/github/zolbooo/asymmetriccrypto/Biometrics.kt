package com.github.zolbooo.asymmetriccrypto

import android.content.Context
import androidx.biometric.BiometricManager

object Biometrics {
    fun isBiometryAvailable(context: Context): Boolean {
        val biometricManager = BiometricManager.from(context)
        return biometricManager.canAuthenticate(
            BiometricManager.Authenticators.BIOMETRIC_STRONG
                .or(BiometricManager.Authenticators.BIOMETRIC_WEAK)
        ) == BiometricManager.BIOMETRIC_SUCCESS
    }
}
