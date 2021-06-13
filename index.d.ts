export type APayAllowedCardNetworkType = "amex" | "mastercard"| "visa" | "privatelabel" | "chinaunionpay" | "interac" | "jcb" | "suica" | "cartebancaires" | "idcredit" | "quicpay" | "maestro" | "mada"

export type APayPaymentStatusType = number

export interface APayPaymentSummaryItemType {
  label: string
  amount: string
}

export interface APayRequestDataType {
  merchantIdentifier: string
  supportedNetworks: APayAllowedCardNetworkType[]
  countryCode: string
  currencyCode: string
  paymentSummaryItems: APayPaymentSummaryItemType[]
}

declare class ApplePay {
  static SUCCESS: APayPaymentStatusType
  static FAILURE: APayPaymentStatusType
  static canMakePayments: boolean
  static requestPayment: (requestData: APayRequestDataType) => Promise<string>
  static complete: (status: APayPaymentStatusType) => Promise<void>
}

export { ApplePay }