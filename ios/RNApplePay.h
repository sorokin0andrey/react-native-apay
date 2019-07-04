@import PassKit;

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

@interface RNApplePay : NSObject <RCTBridgeModule, PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, strong) PKPaymentAuthorizationViewController * _Nullable viewController;

@property (nonatomic, strong, nullable) RCTPromiseResolveBlock requestPaymentResolve;
@property (nonatomic, strong, nullable) RCTPromiseResolveBlock completeResolve;
@property (nonatomic, copy, nullable) void (^completion)(PKPaymentAuthorizationStatus);

@end
