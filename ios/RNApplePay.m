
#import "RNApplePay.h"
#import <React/RCTUtils.h>

@implementation RNApplePay

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (NSDictionary *)constantsToExport
{
    return @{
             @"canMakePayments": @([PKPaymentAuthorizationViewController canMakePayments]),
             @"SUCCESS": @(PKPaymentAuthorizationStatusSuccess),
             @"FAILURE": @(PKPaymentAuthorizationStatusFailure),
             @"DISMISSED_ERROR": @"DISMISSED_ERROR",
             };
}

RCT_EXPORT_METHOD(requestPayment:(NSDictionary *)props promiseWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.merchantIdentifier = props[@"merchantIdentifier"];
    paymentRequest.countryCode = props[@"countryCode"];
    paymentRequest.currencyCode = props[@"currencyCode"];
    paymentRequest.supportedNetworks = [self getSupportedNetworks:props];
    paymentRequest.paymentSummaryItems = [self getPaymentSummaryItems:props];
    
    self.viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest: paymentRequest];
    self.viewController.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootViewController = RCTPresentedViewController();
        [rootViewController presentViewController:self.viewController animated:YES completion:nil];
        self.requestPaymentResolve = resolve;
    });
}

RCT_EXPORT_METHOD(complete:(NSNumber *_Nonnull)status promiseWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if (self.completion != NULL) {
        self.completeResolve = resolve;
        if ([status isEqualToNumber: self.constantsToExport[@"SUCCESS"]]) {
            self.completion(PKPaymentAuthorizationStatusSuccess);
        } else {
            self.completion(PKPaymentAuthorizationStatusFailure);
        }
        self.completion = NULL;
    }
}

- (NSArray *_Nonnull)getSupportedNetworks:(NSDictionary *_Nonnull)props
{
    NSMutableDictionary *supportedNetworksMapping = [[NSMutableDictionary alloc] init];
    
    if (@available(iOS 8, *)) {
        [supportedNetworksMapping setObject:PKPaymentNetworkAmex forKey:@"amex"];
        [supportedNetworksMapping setObject:PKPaymentNetworkMasterCard forKey:@"mastercard"];
        [supportedNetworksMapping setObject:PKPaymentNetworkVisa forKey:@"visa"];
    }
    
    if (@available(iOS 9, *)) {
        [supportedNetworksMapping setObject:PKPaymentNetworkDiscover forKey:@"discover"];
        [supportedNetworksMapping setObject:PKPaymentNetworkPrivateLabel forKey:@"privatelabel"];
    }
    
    if (@available(iOS 9.2, *)) {
        [supportedNetworksMapping setObject:PKPaymentNetworkChinaUnionPay forKey:@"chinaunionpay"];
        [supportedNetworksMapping setObject:PKPaymentNetworkInterac forKey:@"interac"];
    }
    
    if (@available(iOS 10.1, *)) {
        [supportedNetworksMapping setObject:PKPaymentNetworkJCB forKey:@"jcb"];
        [supportedNetworksMapping setObject:PKPaymentNetworkSuica forKey:@"suica"];
    }
    
    if (@available(iOS 10.3, *)) {
        [supportedNetworksMapping setObject:PKPaymentNetworkCarteBancaire forKey:@"cartebancaires"];
        [supportedNetworksMapping setObject:PKPaymentNetworkIDCredit forKey:@"idcredit"];
        [supportedNetworksMapping setObject:PKPaymentNetworkQuicPay forKey:@"quicpay"];
    }
    
    if (@available(iOS 11.0, *)) {
        [supportedNetworksMapping setObject:PKPaymentNetworkCarteBancaires forKey:@"cartebancaires"];
    }
    
    if (@available(iOS 12.0, *)) {
        [supportedNetworksMapping setObject:PKPaymentNetworkMaestro forKey:@"maestro"];
    }

    if (@available(iOS 14.0, *)) {
            [supportedNetworksMapping setObject:PKPaymentNetworkMada forKey:@"mada"];
        }
    
    NSArray *supportedNetworksProp = props[@"supportedNetworks"];
    NSMutableArray *supportedNetworks = [NSMutableArray array];
    for (NSString *supportedNetwork in supportedNetworksProp) {
        [supportedNetworks addObject: supportedNetworksMapping[supportedNetwork]];
    }
    
    return supportedNetworks;
}

- (NSArray<PKPaymentSummaryItem *> *_Nonnull)getPaymentSummaryItems:(NSDictionary *_Nonnull)props
{
    NSMutableArray <PKPaymentSummaryItem *> * paymentSummaryItems = [NSMutableArray array];
    
    NSArray *displayItems = props[@"paymentSummaryItems"];
    if (displayItems.count > 0) {
        for (NSDictionary *displayItem in displayItems) {
            NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:displayItem[@"amount"]];
            NSString *label = displayItem[@"label"];
            [paymentSummaryItems addObject: [PKPaymentSummaryItem summaryItemWithLabel:label amount:amount]];
        }
    }
    
    return paymentSummaryItems;
}

- (void) paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                        didAuthorizePayment:(PKPayment *)payment
                                 completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    self.completion = completion;
    if (self.requestPaymentResolve != NULL) {
        NSString *paymentData = [[NSString alloc] initWithData:payment.token.paymentData encoding:NSUTF8StringEncoding];
        self.requestPaymentResolve(paymentData);
        self.requestPaymentResolve = NULL;
    }
}

- (void)paymentAuthorizationViewControllerDidFinish:(nonnull PKPaymentAuthorizationViewController *)controller {
    dispatch_async(dispatch_get_main_queue(), ^{
        [controller dismissViewControllerAnimated:YES completion:^void {
            if (self.completeResolve != NULL) {
                self.completeResolve(nil);
                self.completeResolve = NULL;
            }
        }];
    });
}

@end
