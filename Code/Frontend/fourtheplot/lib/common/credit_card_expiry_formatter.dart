import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreditCardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var oldS = oldValue.text;
    var newS = newValue.text;
    var endsWithSeparator = false;

    // if you add text
    if (newS.length > oldS.length) {
      if (newS.substring(0, newS.length - 1).endsWith('/')) {
        endsWithSeparator = true;
      }

      var clean = newS.replaceAll('/', '');
      if (!endsWithSeparator && clean.length > 1 && clean.length % 2 == 1) {
        return newValue.copyWith(
          text: '${newS.substring(0, newS.length - 1)}/${newS.characters.last}',
          selection: TextSelection.collapsed(offset: newValue.selection.end + 1),
        );
      }
    }

    // if you delete text
    if (newS.length < oldS.length) {
      if (oldS.substring(0, oldS.length - 1).endsWith('/')) {
        endsWithSeparator = true;
      }

      var clean = oldS.substring(0, oldS.length - 1).replaceAll('/', '');

      if (endsWithSeparator && clean.isNotEmpty && clean.length % 2 == 0) {
        return newValue.copyWith(
          text: newS.substring(0, newS.length - 1),
          selection: TextSelection.collapsed(offset: newValue.selection.end - 1),
        );
      }
    }

    return newValue;
  }
}
