import 'package:apex_flutterwave/flutterwave.dart';

abstract class TransactionCallBack {
  onTransactionComplete(ChargeResponse? chargeResponse);
}