import 'dart:convert';

import 'package:e_com/core/core.dart';

import 'region_model.dart';

enum PaymentMethod {
  stripe,
  paypal,
  payStack,
  flutterWave,
  razorPay,
  instaMojo,
  bkash,
  nagad;

  const PaymentMethod();

  static PaymentMethod? fromName(String? name) => switch (name) {
        'Stripe' => stripe,
        'Paypal' => paypal,
        'Paystack' => payStack,
        'Flutterwave' => flutterWave,
        'Razorpay' => razorPay,
        'Instamojo' => instaMojo,
        'bkash' => bkash,
        'Nagad' => nagad,
        _ => null,
      };
}

class PaymentData {
  PaymentData({
    required this.percentCharge,
    required this.currency,
    required this.rate,
    required this.name,
    required this.uniqueCode,
    required this.paymentParameter,
    required this.image,
    required this.callbackUrl,
  });

  factory PaymentData.fromMap(Map<String, dynamic> map) {
    return PaymentData(
      percentCharge: (map['percent_charge'] as String).asDouble,
      currency: CurrencyData.fromMap(map['currency']),
      rate: map['rate'] ?? '',
      name: map['name'] ?? '',
      uniqueCode: map['unique_code'] ?? '',
      paymentParameter: Map<String, dynamic>.from(map['payment_parameter']),
      image: map['image'] ?? '',
      callbackUrl: map['callback_url'] ?? '',
    );
  }

  final CurrencyData currency;
  final String image;
  final String name;
  final Map<String, dynamic> paymentParameter;
  final double percentCharge;
  final String rate;
  final String uniqueCode;
  final String callbackUrl;

  Map<String, dynamic> toMap() => {
        'percent_charge': percentCharge.toString(),
        'currency': currency.toMap(),
        'rate': rate,
        'name': name,
        'unique_code': uniqueCode,
        'payment_parameter': paymentParameter,
        'image': image,
        'callback_url': callbackUrl,
      };

  String toJson() => json.encode(toMap());

  static PaymentData codPayment = PaymentData(
    percentCharge: 0,
    currency: CurrencyData(uid: '', name: '', symbol: '', rate: 0),
    rate: '',
    name: 'Cash on Delivery',
    uniqueCode: '1',
    paymentParameter: {},
    image: 'COD',
    callbackUrl: '',
  );

  bool get isCOD => uniqueCode == '1';
}
