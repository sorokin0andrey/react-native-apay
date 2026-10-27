# Example

React Native 0.88 app for trying `react-native-apay`.

From the repository root:

```sh
npm install
npm --prefix Example install
npm --prefix Example run ios
```

Replace `merchant.com.payture.applepay.Busfor` in `App.tsx` and `ios/Example/Example.entitlements` with your own Apple Pay merchant identifier. The Apple Pay capability also has to be enabled for the signing team that builds the app.

Apple Pay does not run on Android. The Android project is the stock React Native shell and the payment buttons throw there.
