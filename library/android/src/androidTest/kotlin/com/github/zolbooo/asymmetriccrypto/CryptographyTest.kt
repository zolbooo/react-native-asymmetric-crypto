package com.github.zolbooo.asymmetriccrypto

import android.util.Base64
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class CryptographyTest {
    private val secp256r1HeaderBase64 = "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgA="
    private val secp256r1Header = Base64.decode(secp256r1HeaderBase64, Base64.DEFAULT)

    // See: https://datatracker.ietf.org/doc/html/rfc5480#section-2.2
    private val ecUncompressedKey = 0x04.toByte()
    private val ecCompressedEven = 0x02.toByte()
    private val ecCompressedOdd = 0x03.toByte()

    @Test
    fun shouldGenerateValidDERKey() {
        val publicKeyBase64 = Cryptography.generateKey(
            "test",
            Cryptography.KeySecurityLevel.NONE,
            ApplicationProvider.getApplicationContext(),
        )
        val publicKey = Base64.decode(publicKeyBase64, Base64.DEFAULT)
        assertTrue(
            publicKey.take(secp256r1Header.size).toByteArray().contentEquals(secp256r1Header)
        )

        val publicKeyData = publicKey.drop(secp256r1Header.size)
        assertTrue(
            publicKeyData[0] == ecUncompressedKey ||
                    publicKeyData[0] == ecCompressedEven ||
                    publicKeyData[0] == ecCompressedOdd
        )

        val coordinateLength = 32
        val typeLength = 1
        assertEquals(
            publicKeyData.size, when (publicKeyData[0]) {
                ecUncompressedKey -> typeLength + coordinateLength * 2
                ecCompressedEven, ecCompressedOdd -> typeLength + coordinateLength
                else -> error("Unreachable")
            }
        )
    }
}