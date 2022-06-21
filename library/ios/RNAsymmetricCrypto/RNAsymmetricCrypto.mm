#import "RNAsymmetricCrypto.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <Security/Security.h>

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

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeRNAsymmetricCryptoSpecJSI>(params);
}
#endif
@end
