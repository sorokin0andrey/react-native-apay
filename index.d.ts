import type { APayRequestDataType } from './src/NativeRNApplePay';

export type {
  APayAllowedCardNetworkType,
  APayPaymentSummaryItemType,
  APayRequestDataType,
} from './src/NativeRNApplePay';

export type APayPaymentStatusType = number;

declare class ApplePay {
  static SUCCESS: APayPaymentStatusType;
  static FAILURE: APayPaymentStatusType;
  static canMakePayments: boolean;
  static requestPayment: (
    requestData: APayRequestDataType,
  ) => Promise<string | null>;
  static complete: (status: APayPaymentStatusType) => Promise<void>;
}

export { ApplePay };
