#import "RNAsymmetricCrypto.h"

@implementation RNAsymmetricCrypto

RCT_EXPORT_MODULE(RNAsymmetricCrypto)

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeRNAsymmetricCryptoSpecJSI>(params);
}
#endif
@end
