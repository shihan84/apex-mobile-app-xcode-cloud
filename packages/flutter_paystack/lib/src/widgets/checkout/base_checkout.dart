import 'package:flutter/material.dart';
import 'package:apex_paystack/src/common/paystack.dart';
import 'package:apex_paystack/src/models/checkout_response.dart';
import 'package:apex_paystack/src/widgets/animated_widget.dart';
import 'package:apex_paystack/src/widgets/checkout/checkout_widget.dart';

abstract class BaseCheckoutMethodState<T extends StatefulWidget>
    extends BaseAnimatedState<T> {
  final OnResponse<CheckoutResponse> onResponse;
  final CheckoutMethod _method;

  BaseCheckoutMethodState(this.onResponse, this._method);

  CheckoutMethod get method => _method;
}
