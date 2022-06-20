#import "RNAsymmetricCrypto.h"
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNCalculatorSpec.h"
#endif

@implementation RNAsymmetricCrypto

RCT_EXPORT_MODULE(AsymmetricCrypto)

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeCalculatorSpecJSI>(params);
}
#endif
@end
