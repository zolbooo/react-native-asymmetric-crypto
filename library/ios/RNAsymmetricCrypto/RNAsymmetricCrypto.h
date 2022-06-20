#import <React/RCTBridgeModule.h>
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNAsymmetricCryptoSpec.h"
#endif

#ifdef RCT_NEW_ARCH_ENABLED
@interface RNAsymmetricCrypto : NSObject <NativeRNAsymmetricCryptoSpec>
#else
@interface RNAsymmetricCrypto : NSObject <RCTBridgeModule>
#endif

@end
