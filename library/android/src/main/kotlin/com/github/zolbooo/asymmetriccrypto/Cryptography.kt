package com.github.zolbooo.asymmetriccrypto

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.annotation.RequiresApi
import androidx.core.content.edit
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys
import org.bouncycastle.jce.ECNamedCurveTable
import org.bouncycastle.jce.provider.BouncyCastleProvider
import java.security.KeyPairGenerator
import java.security.SecureRandom
import java.security.Security

object Cryptography {
    init {
        Security.addProvider(BouncyCastleProvider())
    }

    enum class KeySecurityLevel {
        NONE,
        PASSWORD,
        BIOMETRICS
    }

    private fun generateSoftwareECKey(
        alias: String,
        securityLevel: KeySecurityLevel,
        context: Context,
    ): ByteArray {
        val masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC)
        val sharedPreferences = EncryptedSharedPreferences.create(
            "asymmetric_crypto_keys",
            masterKeyAlias,
            context,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )

        val keyPair = KeyPairGenerator.getInstance("ECDSA", "SC").run {
            initialize(ECNamedCurveTable.getParameterSpec("prime256v1"), SecureRandom())
            generateKeyPair()
        }

        val privateBase64 = Base64.encodeToString(keyPair.private.encoded, Base64.DEFAULT)
        val publicBase64 = Base64.encodeToString(keyPair.public.encoded, Base64.DEFAULT)
        sharedPreferences.edit(commit = true) {
            putString("$alias-public", publicBase64)
            putString("$alias-private", privateBase64)
            putString("$alias-security-level", securityLevel.toString())
        }
        return keyPair.public.encoded
    }

    @RequiresApi(23)
    private fun generateECKeyFromKeyStore(
        alias: String,
        securityLevel: KeySecurityLevel
    ): ByteArray {
        val kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore")
        val parameterSpec = KeyGenParameterSpec.Builder(
            alias,
            KeyProperties.PURPOSE_SIGN
                .or(KeyProperties.PURPOSE_VERIFY),
        ).run {
            when (securityLevel) {
                KeySecurityLevel.PASSWORD -> {
                    setUserAuthenticationRequired(true)
                    if (Build.VERSION.SDK_INT >= 28) {
                        setUserConfirmationRequired(true)
                    }
                }
                KeySecurityLevel.BIOMETRICS -> {
                    setUserAuthenticationRequired(true)
                    if (Build.VERSION.SDK_INT >= 28) {
                        setUserConfirmationRequired(true)
                    }
                    if (Build.VERSION.SDK_INT >= 30) {
                        setUserAuthenticationParameters(0, KeyProperties.AUTH_BIOMETRIC_STRONG)
                    }
                }
                KeySecurityLevel.NONE -> {}
            }
            setDigests(KeyProperties.DIGEST_SHA256)
            build()
        }
        return kpg.run {
            initialize(parameterSpec)
            genKeyPair().public.encoded
        }
    }

    fun generateKey(alias: String, securityLevel: KeySecurityLevel, context: Context): String {
        return Base64.encodeToString(
            if (Build.VERSION.SDK_INT < 23) {
                generateSoftwareECKey(alias, securityLevel, context)
            } else {
                generateECKeyFromKeyStore(alias, securityLevel)
            }, Base64.DEFAULT
        )
    }
}