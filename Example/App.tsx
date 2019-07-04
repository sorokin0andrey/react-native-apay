import React, { Component } from 'react'
import { StyleSheet, Text, View, TouchableOpacity } from 'react-native'
import { ApplePay, APayRequestDataType, APayPaymentStatusType } from 'react-native-apay'

const requestData: APayRequestDataType = {
  merchantIdentifier: 'merchant.com.payture.applepay.Busfor',
  supportedNetworks: ['mastercard', 'visa'],
  countryCode: 'US',
  currencyCode: 'USD',
  paymentSummaryItems: [
    {
      label: 'Item label',
      amount: '100.00',
    },
  ],
}

export default class App extends Component {

  payWithApplePay = (status: APayPaymentStatusType) => {
    // Check if ApplePay is available
    if (ApplePay.canMakePayments) {
      ApplePay.requestPayment(requestData)
        .then((paymentData) => {
          // In Sumilator always returns an empty string
          console.log({ paymentData })
          // Simulate a request to the gateway
          setTimeout(() => {
            // Show status to user ApplePay.SUCCESS || ApplePay.FAILURE
            ApplePay.complete(status)
              .then(() => {
                console.log('completed')
                // do something
              })
          }, 1000)
        })
    }
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Welcome to react-native-apay!</Text>
        <TouchableOpacity style={styles.button} onPress={() => this.payWithApplePay(ApplePay.SUCCESS)}>
          <Text style={styles.buttonText}>Buy with Apple Pay (SUCCESS)</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.button} onPress={() => this.payWithApplePay(ApplePay.FAILURE)}>
          <Text style={styles.buttonText}>Buy with Apple Pay (FAILURE)</Text>
        </TouchableOpacity>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
  },
  welcome: {
    fontSize: 18,
    color: '#222',
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
