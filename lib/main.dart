import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Phone Auth '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _numCont = TextEditingController();
  final TextEditingController _otpCont = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextButton(
                onPressed: () {
                  FirebaseAuth.instance.authStateChanges().listen((User? user) {
                    if (user == null) {
                      print('User is currently signed out!');
                    } else {
                      print('User is signed in!');
                      print(user.phoneNumber);
                    }
                  });
                },
                child: const Text('Get Auth')),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextField(
                controller: _numCont,
                keyboardType: TextInputType.number,
                // ignore: prefer_const_constructors
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  labelText: 'Phone ',
                  hintText: 'Enter Phone Number',
                  icon: const Icon(Icons.phone_android),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                  onPressed: () async {
                    print(_numCont.text);
                    await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: '+91 ${_numCont.text}',
                      verificationCompleted: (PhoneAuthCredential credential) {
                        print('Verification Completed');
                      },
                      verificationFailed: (FirebaseAuthException e) {
                        print('Verification Failed: $e');
                      },
                      codeSent: (String verificationId, int? resendToken) {
                        print('codeSent ');
                        print(verificationId);
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {
                        print('AutoCodeRetrieval');
                      },
                    );
                  },
                  child: const Text('Send OTP')),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextField(
                controller: _otpCont,
                keyboardType: TextInputType.number,
                // ignore: prefer_const_constructors
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  labelText: 'OTP',
                  hintText: 'Enter OTP here ',
                  icon: const Icon(Icons.password),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: '+91 ${_numCont.text}',
                      verificationCompleted:
                          (PhoneAuthCredential credential) async {
                        await FirebaseAuth.instance
                            .signInWithCredential(credential);
                      },
                      verificationFailed: (FirebaseAuthException e) async {
                        if (e.code == 'invalid-phone-number') {
                          print('The provided phone number is not valid.');
                        } else {
                          print('Failed due to : $e');
                        }
                      },
                      codeSent:
                          (String verificationId, int? resendToken) async {
                        PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: verificationId,
                                smsCode: _otpCont.text);

                        // Sign the user in (or link) with the credential
                        await FirebaseAuth.instance
                            .signInWithCredential(credential);
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {
                        print('AutoCodeRetrieval');
                      },
                    );
                  },
                  child: const Text('Verify OTP')),
            )
          ],
        ),
      ),
    );
  }
}
