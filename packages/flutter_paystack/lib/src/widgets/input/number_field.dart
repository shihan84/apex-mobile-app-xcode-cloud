import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apex_paystack/src/common/card_utils.dart';
import 'package:apex_paystack/src/common/my_strings.dart';
import 'package:apex_paystack/src/models/card.dart';
import 'package:apex_paystack/src/widgets/common/input_formatters.dart';
import 'package:apex_paystack/src/widgets/input/base_field.dart';

class NumberField extends BaseTextField {
  final PaymentCard? card;
  final bool isDarkMode;
  final Color? darkModeTextColor;

  NumberField({
    Key? key,
    required this.card,
    required TextEditingController? controller,
    required FormFieldSetter<String> onSaved,
    required Widget suffix,
    this.isDarkMode = false,
    this.darkModeTextColor,
  }) : super(
          key: key,
          labelText: 'CARD NUMBER',
          hintText: '0000 0000 0000 0000',
          controller: controller,
          onSaved: onSaved,
          suffix: suffix,
          validator: (String? value) => validateCardNum(value, card),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19),
            CardNumberInputFormatter(),
          ],
        );

  static String? validateCardNum(String? input, PaymentCard? card) {
    if (input == null || input.isEmpty) {
      return Strings.invalidNumber;
    }

    input = CardUtils.getCleanedNumber(input);

    return card!.validNumber(input) ? null : Strings.invalidNumber;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      borderRadius: BorderRadius.circular(4),
      child: TextFormField(
        controller: controller,
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
          suffixIcon: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8), child: suffix),
          ),
        ),
        style: TextStyle(
            color:
                isDarkMode ? darkModeTextColor : theme.colorScheme.onSurface),
        validator: (value) => validateCardNum(value, card),
        inputFormatters: inputFormatters,
        onSaved: onSaved,
      ),
    );
  }
}
