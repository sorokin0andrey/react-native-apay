export type APayAllowedCardNetworkType = "amex" | "masterCard"| "visa" | "privatelabel" | "chinaUnionPay" | "interac" | "jcb" | "suica" | "cartebancaires" | "idcredit" | "quicpay" | "maestro" | "discover" | "cartesBancaires" | "eftpos" | "electron" | "elo" | "girocard" | "mada" | "mir" | "vPay"

export type APayPaymentStatusType = number

export interface APayPaymentSummaryItemType {
  label: string
  amount: string
  pending?: boolean
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
  static requestPayment: (requestData: APayRequestDataType) => Promise<string|null>
  static complete: (status: APayPaymentStatusType) => Promise<void>
}

export { ApplePay }
