import { Platform } from 'react-native';
import NativeRNApplePay from './src/NativeRNApplePay';

const unsupported = () => {
  throw new Error('Apple Pay is available on iOS only');
};

const unsupportedApplePay = {
  canMakePayments: false,
  SUCCESS: 0,
  FAILURE: 1,
  requestPayment: unsupported,
  complete: unsupported,
};

function createApplePay() {
  if (Platform.OS !== 'ios' || NativeRNApplePay == null) {
    return unsupportedApplePay;
  }

  const constants = NativeRNApplePay.getConstants();

  return {
    canMakePayments: constants.canMakePayments,
    SUCCESS: constants.SUCCESS,
    FAILURE: constants.FAILURE,
    requestPayment(requestData) {
      return NativeRNApplePay.requestPayment(requestData);
    },
    complete(status) {
      return NativeRNApplePay.complete(status);
    },
  };
}

export const ApplePay = createApplePay();
