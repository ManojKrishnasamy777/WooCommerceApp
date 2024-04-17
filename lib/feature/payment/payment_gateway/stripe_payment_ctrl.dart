// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:e_com/core/core.dart';
import 'package:e_com/feature/check_out/providers/provider.dart';
import 'package:e_com/feature/payment/repository/payment_repo.dart';
import 'package:e_com/models/models.dart';
import 'package:e_com/routes/routes.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as st;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final stripePaymentCtrlProvider = AutoDisposeNotifierProviderFamily<
    StripePaymentCtrlNotifier,
    String,
    PaymentData>(StripePaymentCtrlNotifier.new);

class StripePaymentCtrlNotifier
    extends AutoDisposeFamilyNotifier<String, PaymentData> {
  @override
  String build(PaymentData arg) {
    return '';
  }

  Dio get _dio => Dio()..interceptors.add(DioClient.talkerDioLogger);
  final _stripe = st.Stripe.instance;

  StripeParam get _cred => StripeParam.fromMap(arg.paymentParameter);

  /// Start Stripe payment Process
  Future<void> initializePayment(context) async {
    st.Stripe.publishableKey = _cred.publishableKey;
    await _stripe.applySettings();

    RouteNames.stripePayment.goNamed(context, extra: 'url');
  }

  // creates payment intent from stripe API
  Future<Map<String, dynamic>> _createCustomer() async {
    const api = 'https://api.stripe.com/v1/customers';
    final order = _order!.order;

    final body = {
      'name': order.billingInformation?.fullName,
      'email': order.billingInformation?.email,
      'phone': order.billingInformation?.phone,
      'shipping': {
        'name': order.billingInformation?.fullName,
        'address': {
          'line1': order.billingInformation?.address,
          'city': order.billingInformation?.city,
          'postal_code': order.billingInformation?.zip,
          'state': order.billingInformation?.state,
        },
      },
    };

    final option = Options(
      headers: {
        'Authorization': 'Bearer ${_cred.secretKey}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    final response = await _dio.post(api, data: body, options: option);

    return response.data;
  }

  Future<void> confirmPayment(context) async {
    try {
      final customer = await _createCustomer();

      final paymentIntentApi = await _createPaymentIntent(customer['id']);

      final clientSecret = paymentIntentApi['client_secret'];

      await _stripe.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: st.PaymentMethodParams.card(
          paymentMethodData: st.PaymentMethodData(
            billingDetails: _billingDetails(),
          ),
        ),
      );

      final token = await _stripe.createToken(
        st.CreateTokenParams.card(
          params: st.CardTokenParams(
            type: st.TokenType.Card,
            currency: arg.currency.name,
            address: _billingDetails().address,
            name: _order!.order.billingInformation?.fullName,
          ),
        ),
      );

      final trx = _order!.paymentLog.trx;
      final callbackUrl = '${arg.callbackUrl}/$trx';

      final body = {
        'stripeEmail': _order!.order.billingInformation?.email,
        'stripeToken': token.id,
      };

      await PaymentRepo().confirmPayment(context, body, callbackUrl);
    } on st.StripeException {
      Toaster.showError(AppDefaults.defErrorMsg);
    }
  }

  st.BillingDetails _billingDetails() {
    return st.BillingDetails(
      email: _order!.order.billingInformation?.email,
      name: _order!.order.billingInformation?.fullName,
      phone: _order!.order.billingInformation?.phone,
      address: st.Address(
        city: _order!.order.billingInformation?.city,
        country: '',
        line1: _order!.order.billingInformation?.address,
        line2: '',
        postalCode: _order!.order.billingInformation?.zip,
        state: _order!.order.billingInformation?.state,
      ),
    );
  }

  Future<st.PaymentMethod?> _createPaymentMethod() async {
    try {
      final paymentMethod = await _stripe.createPaymentMethod(
        params: st.PaymentMethodParams.card(
          paymentMethodData: st.PaymentMethodData(
            billingDetails: _billingDetails(),
          ),
        ),
      );

      return paymentMethod;
    } on st.StripeException {
      return null;
    }
  }

  // creates payment intent from stripe API
  Future<Map<String, dynamic>> _createPaymentIntent(customerID) async {
    final currencyCode = arg.currency.name;
    const api = 'https://api.stripe.com/v1/payment_intents';
    final amount = _order!.paymentLog.finalAmount.round();

    final pm = await _createPaymentMethod();

    final body = {
      'amount': (amount * 100).toInt(),
      'currency': currencyCode,
      'payment_method_types[]': 'card',
      'receipt_email': _order!.order.billingInformation?.email,
      'customer': customerID,
      'payment_method': pm?.id,
      'use_stripe_sdk': true,
    };

    final option = Options(
      headers: {
        'Authorization': 'Bearer ${_cred.secretKey}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    final response = await _dio.post(api, data: body, options: option);

    return response.data;
  }

  OrderBaseModel? get _order => ref.read(checkoutStateProvider);
}
