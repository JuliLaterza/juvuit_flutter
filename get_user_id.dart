import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    print('User ID: ${user.uid}');
    print('Email: ${user.email}');
  } else {
    print('No user logged in');
  }
}
