#import "RNAsymmetricCrypto.h"

#import <LocalAuthentication/LocalAuthentication.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>

@implementation RNAsymmetricCrypto

RCT_EXPORT_MODULE(RNAsymmetricCrypto)

RCT_EXPORT_METHOD(getAvailableBiometryType: (RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        LAContext *context = [[LAContext alloc] init];
        NSError *la_error = nil;
        LAPolicy laPolicy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
        BOOL canEvaluatePolicy = [context canEvaluatePolicy:laPolicy error:&la_error];
        if (canEvaluatePolicy) {
            NSString *biometryType;
            if (@available(iOS 11, *)) {
                biometryType = (context.biometryType == LABiometryTypeFaceID) ? @"FaceID" : @"TouchID";
            } else {
                biometryType = @"TouchID";
            }

            NSDictionary *result = @{
                @"available": @(YES),
                @"biometryType": biometryType
            };
            resolve(result);
        } else {
            /*
            TODO: Some error messages could be useful, for example:
            - No fingerprint/face identities enrolled
            In this case we should be able to provide some enum value to the JS side
            */
            NSString *errorMessage = [NSString stringWithFormat:@"%@", la_error];
            NSDictionary *result = @{
                @"available": @(NO),
                @"error": errorMessage
            };
            resolve(result);
        }
    });
}

- (bool)keyExists: (NSString *)alias :(OSStatus *)status {
    NSDictionary *searchQuery = @{
        (id)kSecClass: (id)kSecClassKey,
        (id)kSecAttrApplicationTag: alias,
        (id)kSecAttrKeyType: (id)kSecAttrKeyTypeECSECPrimeRandom,
        (id)kSecUseAuthenticationUI: (id)kSecUseAuthenticationUIFail
    };

    *status = SecItemCopyMatching((__bridge CFDictionaryRef)searchQuery, nil);
    if (*status == errSecSuccess || *status == errSecInteractionNotAllowed) {
        return YES;
    }
    return NO;
}

RCT_EXPORT_METHOD(keyExists: (NSString *)alias
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSStatus status;
        if ([self keyExists:alias :&status]) {
            NSDictionary *result = @{
                @"exists": @(YES),
            };
            resolve(result);
            return;
        }
        if (status == errSecItemNotFound) {
            NSDictionary *result = @{
                @"exists": @(NO),
            };
            resolve(result);
            return;
        }

        NSString *message = [NSString stringWithFormat:@"SecItemCopyMatching failed: %ld", (long)status];
        NSDictionary *result = @{
            @"exists": @(NO),
            @"error": message,
        };
        resolve(result);
    });
}

static const size_t secp256r1HeaderLength = 26;
static const unsigned char secp256r1Header[secp256r1HeaderLength] = {0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, 0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00};

RCT_EXPORT_METHOD(createKey:
#ifdef RCT_NEW_ARCH_ENABLED
                  (JS::NativeRNAsymmetricCrypto::SpecCreateKeyOptions &)options
#else
                  (NSDictionary *)options
#endif
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
// NOTE: Get options before async call to prevent use-after-free
#ifdef RCT_NEW_ARCH_ENABLED
    NSString *alias = options.alias();
    NSString *securityLevel = options.securityLevel();
#else
    NSString *alias = options[@"alias"];
    NSString *securityLevel = options[@"securityLevel"];
#endif
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SecAccessControlCreateFlags flags;

        if ([securityLevel isEqual: @"none"]) {
            flags = kSecAccessControlPrivateKeyUsage;
        } else if ([securityLevel isEqual: @"password"]) {
            flags = kSecAccessControlPrivateKeyUsage | kSecAccessControlDevicePasscode;
        } else if ([securityLevel isEqual: @"biometrics"]) {
            if (@available (iOS 11.3, *)) {
                flags = kSecAccessControlPrivateKeyUsage | kSecAccessControlBiometryCurrentSet;
            } else {
                flags = kSecAccessControlPrivateKeyUsage | kSecAccessControlTouchIDCurrentSet;
            }
        } else {
            NSString *message = [NSString stringWithFormat:@"createKey: unknown securityLevel value %@", securityLevel];
            reject(@"createKey", message, nil);
            return;
        }

        CFErrorRef error = NULL;
        SecAccessControlRef access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                        kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                        flags,
                                        &error);
        if (access == NULL || error != NULL) {
            NSString *errorString = [NSString stringWithFormat:@"SecAccessControlCreateWithFlags failed: %@", error];
            reject(@"createKey", errorString, nil);
            return;
        }

        NSDictionary* attributes = @{
            (id)kSecAttrKeyType:             (id)kSecAttrKeyTypeECSECPrimeRandom,
            (id)kSecAttrKeySizeInBits:       @256,
            (id)kSecAttrTokenID:             (id)kSecAttrTokenIDSecureEnclave,
            (id)kSecPrivateKeyAttrs: @{
                (id)kSecAttrIsPermanent:    @YES,
                (id)kSecAttrApplicationTag: alias,
                (id)kSecAttrAccessControl:  (__bridge id)access,
            },
        };
        SecKeyRef privateKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attributes, &error);
        CFRelease(access);
        if (!privateKey) {
            NSString *message = [NSString stringWithFormat:@"SecKeyCreateRandomKey failed: %@", error];
            reject(@"storage_error", message, nil);
            return;
        }

        id publicKey = CFBridgingRelease(SecKeyCopyPublicKey(privateKey));
        CFRelease(privateKey);

        CFDataRef publicKeyDataRef = SecKeyCopyExternalRepresentation((SecKeyRef)publicKey, nil);
        NSData *publicKeyData = (__bridge NSData *)publicKeyDataRef;

        NSMutableData *publicKeyDER = [[NSMutableData alloc] init];
        [publicKeyDER appendBytes:secp256r1Header length:secp256r1HeaderLength];
        [publicKeyDER appendData:publicKeyData];
        NSString *encodedPublicKey = [publicKeyDER base64EncodedStringWithOptions:0];
        resolve(@{
            @"publicKey": encodedPublicKey,
        });
    });
}

RCT_EXPORT_METHOD(removeKey: (NSString *)alias
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *deleteQuery = @{
            (id)kSecClass: (id)kSecClassKey,
            (id)kSecAttrApplicationTag: alias,
            (id)kSecAttrKeyType: (id)kSecAttrKeyTypeECSECPrimeRandom
        };
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)deleteQuery);
        if (status == errSecSuccess) {
            resolve(@YES);
        } else {
            NSString *message = [NSString stringWithFormat:@"SecItemDelete failed: %d", (int)status];
            reject(@"removeKey", message, nil);
        }
    });
}

RCT_EXPORT_METHOD(sign:
#ifdef RCT_NEW_ARCH_ENABLED
    (JS::NativeRNAsymmetricCrypto::SpecSignOptions &)options
#else
    (NSDictionary *)options
#endif
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject) {
#ifdef RCT_NEW_ARCH_ENABLED
    NSString *alias = options.alias();
    NSString *dataBase64 = options.dataBase64();
    NSString *prompt = options.prompt();
#else
    NSString *alias = options[@"alias"];
    NSString *dataBase64 = options[@"dataBase64"];
    NSString *prompt = options[@"prompt"];
#endif
    if (prompt == nil) {
        prompt = @"";
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *query = @{
            (id)kSecClass: (id)kSecClassKey,
            (id)kSecAttrApplicationTag: alias,
            (id)kSecAttrKeyType: (id)kSecAttrKeyTypeECSECPrimeRandom,
            (id)kSecReturnRef: @YES,
            (id)kSecUseOperationPrompt: prompt,
        };
        SecKeyRef privateKey;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&privateKey);
        if (!privateKey) {
            NSString *message = [NSString stringWithFormat:@"SecItemCopyMatching: %d", (int)status];
            reject(@"sign", message, nil);
            return;
        }

        NSData *payload = [[NSData alloc] initWithBase64EncodedString:dataBase64 options:0];
        if (payload == nil) {
            reject(@"sign", @"Invalid base64", nil);
            return;
        }
        NSMutableData *dataDigest = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
        CC_SHA256(payload.bytes, payload.length, (unsigned char *)dataDigest.mutableBytes);

        CFErrorRef errorRef = NULL;
        NSData *signature = CFBridgingRelease(SecKeyCreateSignature(privateKey, kSecKeyAlgorithmECDSASignatureDigestX962SHA256, (CFDataRef)dataDigest, &errorRef));
        if (signature == nil) {
            NSError *error = (__bridge NSError *)errorRef;
            if (error.code == errSecUserCanceled) {
                reject(@"sign", @"User cancelled request", nil);
                return;
            }
            NSString *message = [NSString stringWithFormat:@"SecKeyCreateSignature failed: %@", error];
            reject(@"sign", message, nil);
            return;
        }

        resolve([signature base64EncodedStringWithOptions:0]);
    });
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeRNAsymmetricCryptoSpecJSI>(params);
}
#endif
@end
