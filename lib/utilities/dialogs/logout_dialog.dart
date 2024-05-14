import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Log out',
    content: 'Are you sure about this?',
    optionsBuilder: () => {
      'Cancel': false,
      'Confirm': true,
    }
  ).then((value) => value ?? false);
}