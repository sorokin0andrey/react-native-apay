import { TurboModuleRegistry, type TurboModule } from 'react-native';

export type APayAllowedCardNetworkType =
  | 'amex'
  | 'masterCard'
  | 'visa'
  | 'privatelabel'
  | 'chinaUnionPay'
  | 'interac'
  | 'jcb'
  | 'suica'
  | 'cartebancaires'
  | 'idcredit'
  | 'quicpay'
  | 'maestro'
  | 'discover'
  | 'cartesBancaires'
  | 'eftpos'
  | 'electron'
  | 'elo'
  | 'girocard'
  | 'mada'
  | 'mir'
  | 'vPay'
  | 'bancontact'
  | 'barcode'
  | 'dankort'
  | 'nanaco'
  | 'postFinance'
  | 'waon';

export type APayMerchantCapability =
  | '3DS'
  | 'EMV'
  | 'Credit'
  | 'Debit'
  | 'InstantFundsOut';

export interface APayPaymentSummaryItemType {
  label: string;
  amount: string;
  pending?: boolean;
}

export interface APayRequestDataType {
  merchantIdentifier: string;
  /**
   * Cryptographic protocol and card type filter.
   * At least one of `3DS` or `EMV` is required when this is set.
   * Omit it to keep the default, 3-D Secure.
   */
  merchantCapabilities?: APayMerchantCapability[];
  supportedNetworks: APayAllowedCardNetworkType[];
  countryCode: string;
  currencyCode: string;
  paymentSummaryItems: APayPaymentSummaryItemType[];
}

export interface Spec extends TurboModule {
  getConstants(): {
    canMakePayments: boolean;
    SUCCESS: number;
    FAILURE: number;
  };
  requestPayment(requestData: APayRequestDataType): Promise<string | null>;
  complete(status: number): Promise<void>;
}

export default TurboModuleRegistry.get<Spec>('RNApplePay');
