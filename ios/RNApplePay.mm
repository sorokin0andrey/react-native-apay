#import "RNApplePay.h"
#import <PassKit/PassKit.h>

#if __has_include("RNApplePay/RNApplePay-Swift.h")
#import "RNApplePay/RNApplePay-Swift.h"
#elif __has_include(<RNApplePay/RNApplePay-Swift.h>)
#import <RNApplePay/RNApplePay-Swift.h>
#else
#import "RNApplePay-Swift.h"
#endif

@implementation RNApplePay {
  RNApplePayImpl *_impl;
}

- (instancetype)init
{
  if (self = [super init]) {
    _impl = [RNApplePayImpl new];
  }
  return self;
}

+ (NSString *)moduleName
{
  return @"RNApplePay";
}

- (facebook::react::ModuleConstants<JS::NativeRNApplePay::Constants>)getConstants
{
  return facebook::react::typedConstants<JS::NativeRNApplePay::Constants>({
    .canMakePayments = _impl.canMakePayments,
    .SUCCESS = _impl.successStatus.doubleValue,
    .FAILURE = _impl.failureStatus.doubleValue,
  });
}

- (facebook::react::ModuleConstants<JS::NativeRNApplePay::Constants>)constantsToExport
{
  return [self getConstants];
}

- (void)requestPayment:(JS::NativeRNApplePay::APayRequestDataType &)requestData
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject
{
  NSMutableDictionary *payload = [@{
    @"merchantIdentifier" : requestData.merchantIdentifier(),
    @"supportedNetworks" : requestData.supportedNetworks().unsafeRawValue(),
    @"countryCode" : requestData.countryCode(),
    @"currencyCode" : requestData.currencyCode(),
    @"paymentSummaryItems" : requestData.paymentSummaryItems().unsafeRawValue(),
  } mutableCopy];
  auto capabilities = requestData.merchantCapabilities();
  if (capabilities.has_value()) {
    payload[@"merchantCapabilities"] = capabilities->unsafeRawValue();
  }
  [_impl requestPayment:payload resolve:resolve reject:reject];
}

- (void)complete:(double)status
         resolve:(RCTPromiseResolveBlock)resolve
          reject:(RCTPromiseRejectBlock)reject
{
  [_impl complete:@(status) resolve:resolve reject:reject];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeRNApplePaySpecJSI>(params);
}

@end
