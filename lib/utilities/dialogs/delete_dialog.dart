import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Confirmation',
    content: 'Confirm delete this note?',
    optionsBuilder: () => {
      'NO': false,
      'YES': true,
    }
  ).then((value) => value ?? false);
}