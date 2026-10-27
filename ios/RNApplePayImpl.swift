import PassKit
import UIKit

@objc(RNApplePayImpl)
public final class RNApplePayImpl: NSObject, PKPaymentAuthorizationViewControllerDelegate {
  private var viewController: PKPaymentAuthorizationViewController?
  private var requestPaymentResolve: ((Any?) -> Void)?
  private var completeResolve: ((Any?) -> Void)?
  private var authorizationCompletion: ((PKPaymentAuthorizationResult) -> Void)?

  @objc public var canMakePayments: Bool {
    PKPaymentAuthorizationViewController.canMakePayments()
  }

  @objc public var successStatus: NSNumber {
    NSNumber(value: PKPaymentAuthorizationStatus.success.rawValue)
  }

  @objc public var failureStatus: NSNumber {
    NSNumber(value: PKPaymentAuthorizationStatus.failure.rawValue)
  }

  @objc(requestPayment:resolve:reject:)
  public func requestPayment(
    _ requestData: NSDictionary,
    resolve: @escaping (Any?) -> Void,
    reject: @escaping (String, String, NSError?) -> Void
  ) {
    let present = {
      self.presentPayment(requestData, resolve: resolve, reject: reject)
    }

    if Thread.isMainThread {
      present()
    } else {
      DispatchQueue.main.async(execute: present)
    }
  }

  @objc(complete:resolve:reject:)
  public func complete(
    _ status: NSNumber,
    resolve: @escaping (Any?) -> Void,
    reject: @escaping (String, String, NSError?) -> Void
  ) {
    let finish = {
      _ = reject
      guard let authorizationCompletion = self.authorizationCompletion else {
        resolve(nil)
        return
      }

      self.authorizationCompletion = nil
      self.completeResolve = resolve
      let paymentStatus: PKPaymentAuthorizationStatus =
        status.intValue == PKPaymentAuthorizationStatus.success.rawValue ? .success : .failure
      authorizationCompletion(PKPaymentAuthorizationResult(status: paymentStatus, errors: nil))
    }

    if Thread.isMainThread {
      finish()
    } else {
      DispatchQueue.main.async(execute: finish)
    }
  }

  public func paymentAuthorizationViewController(
    _ controller: PKPaymentAuthorizationViewController,
    didAuthorizePayment payment: PKPayment,
    handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
  ) {
    authorizationCompletion = completion
    let paymentData = paymentResult(from: payment)
    let resolve = requestPaymentResolve
    requestPaymentResolve = nil
    resolve?(paymentData)
  }

  public func paymentAuthorizationViewControllerDidFinish(
    _ controller: PKPaymentAuthorizationViewController
  ) {
    let closeSheet = {
      controller.dismiss(animated: true) {
        let completeResolve = self.completeResolve
        self.completeResolve = nil
        completeResolve?(nil)

        // The sheet was dismissed before authorization. Same contract as
        // https://github.com/sorokin0andrey/react-native-apay/pull/39
        let requestResolve = self.requestPaymentResolve
        self.requestPaymentResolve = nil
        requestResolve?(nil)

        self.viewController = nil
      }
    }

    if Thread.isMainThread {
      closeSheet()
    } else {
      DispatchQueue.main.async(execute: closeSheet)
    }
  }

  private func presentPayment(
    _ requestData: NSDictionary,
    resolve: @escaping (Any?) -> Void,
    reject: @escaping (String, String, NSError?) -> Void
  ) {
    if viewController != nil {
      reject(
        "E_APPLE_PAY_IN_PROGRESS",
        "An Apple Pay sheet is already presented",
        nil
      )
      return
    }

    guard
      let merchantIdentifier = requestData["merchantIdentifier"] as? String,
      let countryCode = requestData["countryCode"] as? String,
      let currencyCode = requestData["currencyCode"] as? String,
      !merchantIdentifier.isEmpty,
      !countryCode.isEmpty,
      !currencyCode.isEmpty
    else {
      reject(
        "E_APPLE_PAY_INVALID_REQUEST",
        "merchantIdentifier, countryCode and currencyCode are required",
        nil
      )
      return
    }

    let request = PKPaymentRequest()
    request.merchantCapabilities = merchantCapabilities(from: requestData)
    request.merchantIdentifier = merchantIdentifier
    request.countryCode = countryCode
    request.currencyCode = currencyCode
    request.supportedNetworks = supportedNetworks(from: requestData)
    request.paymentSummaryItems = summaryItems(from: requestData)

    guard let controller = PKPaymentAuthorizationViewController(paymentRequest: request) else {
      reject(
        "E_APPLE_PAY_UNAVAILABLE",
        "Apple Pay cannot present this payment request",
        nil
      )
      return
    }

    guard let presenter = topViewController() else {
      reject(
        "E_APPLE_PAY_PRESENTATION",
        "Unable to find a view controller to present Apple Pay",
        nil
      )
      return
    }

    controller.delegate = self
    viewController = controller
    requestPaymentResolve = resolve
    presenter.present(controller, animated: true)
  }

  private func paymentResult(from payment: PKPayment) -> String? {
    guard
      let paymentData = String(data: payment.token.paymentData, encoding: .utf8),
      let paymentDataBytes = paymentData.data(using: .utf8),
      let paymentDataObject = try? JSONSerialization.jsonObject(with: paymentDataBytes)
    else {
      return String(data: payment.token.paymentData, encoding: .utf8)
    }

    let payload: [String: Any] = [
      "paymentData": paymentDataObject,
      "transactionIdentifier": payment.token.transactionIdentifier,
      "paymentMethod": paymentMethodObject(payment.token.paymentMethod),
    ]
    guard
      let data = try? JSONSerialization.data(withJSONObject: payload),
      let json = String(data: data, encoding: .utf8)
    else {
      return paymentData
    }
    return json
  }

  private func paymentMethodObject(_ method: PKPaymentMethod) -> [String: String] {
    var result = ["type": paymentMethodType(method.type)]
    if let displayName = method.displayName {
      result["displayName"] = displayName
    }
    if let network = method.network?.rawValue {
      result["network"] = network
    }
    return result
  }

  private func paymentMethodType(_ type: PKPaymentMethodType) -> String {
    switch type {
    case .debit:
      return "debit"
    case .credit:
      return "credit"
    case .prepaid:
      return "prepaid"
    case .store:
      return "store"
    case .eMoney:
      return "eMoney"
    default:
      return "unknown"
    }
  }

  private func merchantCapabilities(from requestData: NSDictionary) -> PKMerchantCapability {
    guard
      let requested = requestData["merchantCapabilities"] as? [String],
      !requested.isEmpty
    else {
      return .threeDSecure
    }

    var capabilities: PKMerchantCapability = []
    if requested.contains("3DS") {
      capabilities.insert(.threeDSecure)
    }
    if requested.contains("EMV") {
      capabilities.insert(.emv)
    }
    if requested.contains("Credit") {
      capabilities.insert(.credit)
    }
    if requested.contains("Debit") {
      capabilities.insert(.debit)
    }
    if #available(iOS 17.0, *), requested.contains("InstantFundsOut") {
      capabilities.insert(.instantFundsOut)
    }

    if !capabilities.contains(.threeDSecure) && !capabilities.contains(.emv) {
      capabilities.insert(.threeDSecure)
    }
    return capabilities
  }

  private func supportedNetworks(from requestData: NSDictionary) -> [PKPaymentNetwork] {
    guard let requested = requestData["supportedNetworks"] as? [Any] else {
      return []
    }

    return requested.compactMap { item in
      guard let key = item as? String else {
        return nil
      }
      return Self.networks[key]
    }
  }

  private func summaryItems(from requestData: NSDictionary) -> [PKPaymentSummaryItem] {
    guard let items = requestData["paymentSummaryItems"] as? [Any] else {
      return []
    }

    return items.compactMap { entry in
      guard
        let item = entry as? NSDictionary,
        let label = item["label"] as? String,
        let amount = item["amount"] as? String
      else {
        return nil
      }

      let pending = (item["pending"] as? Bool) ?? false
      return PKPaymentSummaryItem(
        label: label,
        amount: NSDecimalNumber(string: amount, locale: Locale(identifier: "en_US_POSIX")),
        type: pending ? .pending : .final
      )
    }
  }

  private func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let window = scenes.flatMap(\.windows).first(where: \.isKeyWindow) ?? scenes.flatMap(\.windows).first
    var top = window?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }

  private static let networks: [String: PKPaymentNetwork] = {
    var networks: [String: PKPaymentNetwork] = [
      "amex": .amex,
      "masterCard": .masterCard,
      "mastercard": .masterCard,
      "visa": .visa,
      "privateLabel": .privateLabel,
      "privatelabel": .privateLabel,
      "discover": .discover,
      "chinaUnionPay": .chinaUnionPay,
      "interac": .interac,
      "jcb": .JCB,
      "suica": .suica,
      "carteBancaires": .carteBancaires,
      "cartebancaires": .carteBancaires,
      "idcredit": .idCredit,
      "quicpay": .quicPay,
      "cartesBancaires": .cartesBancaires,
      "maestro": .maestro,
      "eftpos": .eftpos,
      "electron": .electron,
      "vPay": .vPay,
      "elo": .elo,
      "girocard": .girocard,
      "mada": .mada,
      "mir": .mir,
      "barcode": .barcode,
      "dankort": .dankort,
      "nanaco": .nanaco,
      "waon": .waon,
    ]

    if #available(iOS 16.0, *) {
      networks["bancontact"] = .bancontact
    }
    if #available(iOS 16.4, *) {
      networks["postFinance"] = .postFinance
      networks["postfinance"] = .postFinance
    }
    return networks
  }()
}
