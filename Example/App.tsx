import { useState } from 'react';
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import {
  ApplePay,
  type APayPaymentStatusType,
  type APayRequestDataType,
} from 'react-native-apay';

const requestData: APayRequestDataType = {
  merchantIdentifier: 'merchant.com.payture.applepay.Busfor',
  supportedNetworks: ['masterCard', 'visa'],
  countryCode: 'US',
  currencyCode: 'USD',
  paymentSummaryItems: [
    {
      label: 'Item label',
      amount: '100.00',
    },
  ],
};

export default function App() {
  const [statusText, setStatusText] = useState('Ready');

  const pay = (status: APayPaymentStatusType) => {
    if (!ApplePay.canMakePayments) {
      setStatusText('Apple Pay is not available on this device');
      return;
    }

    ApplePay.requestPayment(requestData)
      .then(paymentData => {
        if (paymentData == null) {
          setStatusText('Payment cancelled');
          return;
        }

        console.log({ paymentData });
        setTimeout(() => {
          ApplePay.complete(status)
            .then(() => {
              setStatusText(
                status === ApplePay.SUCCESS
                  ? 'Payment completed'
                  : 'Payment failed',
              );
            })
            .catch((error: unknown) => {
              setStatusText(
                error instanceof Error
                  ? error.message
                  : 'Unable to complete payment',
              );
            });
        }, 1000);
      })
      .catch((error: unknown) => {
        setStatusText(
          error instanceof Error ? error.message : 'Unable to start Apple Pay',
        );
      });
  };

  return (
    <View style={styles.container}>
      <Text style={styles.welcome}>Welcome to react-native-apay!</Text>
      <Text style={styles.status}>{statusText}</Text>
      <TouchableOpacity
        style={styles.button}
        onPress={() => pay(ApplePay.SUCCESS)}>
        <Text style={styles.buttonText}>Buy with Apple Pay (SUCCESS)</Text>
      </TouchableOpacity>
      <TouchableOpacity
        style={styles.button}
        onPress={() => pay(ApplePay.FAILURE)}>
        <Text style={styles.buttonText}>Buy with Apple Pay (FAILURE)</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    paddingHorizontal: 24,
  },
  welcome: {
    fontSize: 18,
    color: '#222',
  },
  status: {
    marginTop: 12,
    fontSize: 16,
    color: '#555',
  },
  button: {
    marginTop: 24,
    backgroundColor: '#007aff',
    borderRadius: 14,
    height: 56,
    paddingHorizontal: 24,
    justifyContent: 'center',
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 18,
  },
});
