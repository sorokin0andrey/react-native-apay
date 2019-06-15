
import { NativeModules, Platform } from 'react-native';

const { RNApplePay } = NativeModules;

const throwError = () => {
  throw new Error(`Google Pay is for Android only, use Platform.OS === 'android'`)
};

const mockAndroid = {
  requestPayment: throwError,
  complete: throwError,
};

const ApplePay = Platform.OS === 'ios' ? RNApplePay : mockAndroid

export { ApplePay };
