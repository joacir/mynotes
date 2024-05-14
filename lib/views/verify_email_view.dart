import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Email verification.')),
        body: Column(
          children: [
            const Text('We have sent a email verification. Please open it to verify your account.'),
            const Text('If you havent received email verification. Please click below.'),
            TextButton(
              onPressed: ()  {
                context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
              },
              child: const Text('Send e-mail verification'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
              child: const Text('Restart'),
            ),
          ],
      )
    );
  }
}
