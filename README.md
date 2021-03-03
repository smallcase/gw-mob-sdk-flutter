# Scgateway Flutter plugin.

### Minimum Versions


| Platform | Version |
| -------- | ------- |
| flutter | >=1.20.0 |
| android | minSdkVersion 21 |
| ios | ios 11.0 |

## Getting Started

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  scgateway_flutter_plugin: ^1.0.0
```

From the terminal: Run

```sh
flutter pub get
```

## Android setup

add these lines in `AndroidManifest.xml` in the main `<application />` tag

```xml
<activity android:name="com.smallcase.gateway.screens.transaction.activity.TransactionProcessActivity">
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />

    <category android:name="android.intent.category.BROWSABLE" />
    <category android:name="android.intent.category.DEFAULT" />
    <data
      android:host="{YOUR_HOST_NAME}"
      android:scheme="scgateway" />
  </intent-filter>
</activity>
```

Replace "{YOUR_HOST_NAME}" with unique host name which is given to every integration partners.

---

## Flutter interface

The plugin exports all its methods with one default import. Import it using
```dart
import 'package:{scgateway_flutter_plugin}/scgateway_flutter_plugin.dart';
```


### Setting up sdk for a transaction.

To start using gateway setup the gateway with the desired configuration by calling setConfigEnvironment method which is available as a static method of ScgatewayFlutterPlugin class.

```dart
ScgatewayFlutterPlugin.setConfigEnvironment(enviroment, gateway_name, leprechaun_mode, isAmoEnabled)
```

**Params :**
**environment -** (Required) This defines the Url environment to which all the gateway apis would point to.

```dart
ScgatewayFlutterPlugin.GatewayEnvironment {
  PRODUCTION,
  DEVELOPMENT,
  STAGING
}
```

**gateway_name -** (Required) This is a unique name given to every gateway consumer.
**leprechaun_mode-**(Optional) For Testing purpose pass it as true else false.
**isAmoEnabled-**(Optional) For Testing purpose pass it as true else false.

### User Initialisation

User initialization starts a session between the distributor and the gateway. Whenever there is a change in user session.

```dart
ScgatewayFlutterPlugin.initGateway(authToken);
```

**Params :**
**authToken -** (Required) JWT with the information of user signed using a shared secret between smallcase API and gateway backend.

### Trigger Transaction
To start a transaction call triggerGatewayTransaction method which is available as a static method of ScgatewayFlutterPlugin class.

```dart
ScgatewayFlutterPlugin.triggerGatewayTransaction(transactionId)
```

**Params :**
**transactionId -** (Required) Transaction id to create a the transaction.

---
**NOTE**
TransactionId creation process remains same using Gateway backend APIs.
Read more about transaction Id at [Creating Transactions](https://developers.gateway.smallcase.com/reference/create-transactions)
---

## Lead Gen

To trigger lead gen call **triggerLeadGen** method which is available as a static method on ScgatewayFlutterPlugin class.

```dart
 ScgatewayFlutterPlugin.leadGen(name, email, contact, pincode);
 ```

 **Params :**
**name:** (Optional) Nname ff the User.
**email:** (Optional) Email of the User.
**contact:** (Optional) Contact number of the User.
**pinCode:** (Optional) PIN code of the User.



