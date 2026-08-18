import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apex_paystack/src/common/card_utils.dart';
import 'package:apex_paystack/src/common/my_strings.dart';
import 'package:apex_paystack/src/models/card.dart';
import 'package:apex_paystack/src/widgets/common/input_formatters.dart';
import 'package:apex_paystack/src/widgets/input/base_field.dart';

class DateField extends BaseTextField {
  final bool isDarkMode;
  final Color? darkModeTextColor;

  DateField({
    Key? key,
    required PaymentCard? card,
    required FormFieldSetter<String> onSaved,
    this.isDarkMode = false,
    this.darkModeTextColor,
  }) : super(
          key: key,
          labelText: 'CARD EXPIRY',
          hintText: 'MM/YY',
          validator: validateDate,
          initialValue: _getInitialExpiryMonth(card),
          onSaved: onSaved,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
            CardMonthInputFormatter(),
          ],
        );

  static String? _getInitialExpiryMonth(PaymentCard? card) {
    if (card == null) {
      return null;
    }
    if (card.expiryYear == null ||
        card.expiryMonth == null ||
        card.expiryYear == 0 ||
        card.expiryMonth == 0) {
      return null;
    } else {
      return '${card.expiryMonth}/${card.expiryYear}';
    }
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.invalidExpiry;
    }

    int year;
    int month;

    if (value.contains(RegExp(r'(/)'))) {
      final date = CardUtils.getExpiryDate(value);
      month = date[0];
      year = date[1];
    } else {
      month = int.parse(value.substring(0, (value.length)));
      year = -1;
    }

    if (!CardUtils.isNotExpired(year, month)) {
      return Strings.invalidExpiry;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      borderRadius: BorderRadius.circular(4),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          filled: true,
          fillColor: isDarkMode ? Colors.black : Colors.white,
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white60 : theme.hintColor,
          ),
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.white60 : theme.colorScheme.onSurface,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.secondary),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.secondary),
          ),
        ),
        style: TextStyle(
            color:
                isDarkMode ? darkModeTextColor : theme.colorScheme.onSurface),
        validator: validator,
        inputFormatters: inputFormatters,
        onSaved: onSaved,
      ),
    );
  }
}
