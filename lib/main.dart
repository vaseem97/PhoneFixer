import 'package:app_trp/colors.dart';
import 'package:app_trp/home_page.dart';
import 'package:app_trp/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: Platform.isAndroid
        ? const FirebaseOptions(
            apiKey: "AIzaSyBuNLgkg0fqkg4gUJV7U25d_8v_xvrMy1Q",
            appId: "1:259493388971:android:172d8c94c00f8aa442cdee",
            messagingSenderId: "259493388971",
            projectId: "phonespare-5f9f1",
          )
        : null,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),

        // Other providers...
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartProvider>(
      create: (_) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Email Auth Demo',
        theme: AppTheme.theme,
        home: SignInPage(),
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final String _countryCode = '+91'; // Default country code for India
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PhoneSpare'),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 200.0), // Increased space here
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Login to continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      TextField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        focusNode: _phoneFocusNode,
                        onEditingComplete: _phoneFocusNode.unfocus,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixText: _countryCode,
                          prefixIcon:
                              const Icon(Icons.phone, color: Colors.deepPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.deepPurple,
                              width: 2.0,
                            ),
                          ),
                          labelStyle: const TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signInWithPhoneNumber,
                        child: const Text('Send Verification Code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      if (authProvider.verificationId != null)
                        Column(
                          children: [
                            TextField(
                              controller: _smsCodeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Verification Code',
                                prefixIcon: const Icon(Icons.message,
                                    color: Colors.deepPurple),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                labelStyle:
                                    const TextStyle(color: Colors.deepPurple),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _verifySmsCode,
                              child: const Text('Verify Code'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 32.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('By continuing, you agree to our '),
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                // Show Terms and Conditions dialog or open a web view
                              },
                              child: const Text(
                                'Terms and Conditions',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.deepPurple,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      TextButton(
                        onPressed: _skipSignIn,
                        child: const Text(
                          'Skip Sign In',
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _skipSignIn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ModelListScreen()),
    );
  }

  Future<void> _signInWithPhoneNumber() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final String phoneNumber =
          _countryCode + _phoneNumberController.text.trim();
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          setState(() {
            _isLoading = false;
          });
          // Navigate to the next screen
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ModelListScreen()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Verification Failed: ${e.message}';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          Provider.of<AuthProvider>(context, listen: false).verificationId =
              verificationId;
          setState(() {
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  Future<void> _verifySmsCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String verificationId =
          Provider.of<AuthProvider>(context, listen: false).verificationId!;
      final String smsCode = _smsCodeController.text.trim();
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {
        _isLoading = false;
      });
      //Navigate to the next screen or do any other post-login operations
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ModelListScreen()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid verification code';
      });
    }
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _smsCodeController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }
}

class AuthProvider extends ChangeNotifier {
  String? verificationId;
  FirebaseAuth? _auth;
  User? _user;

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _auth?.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth?.currentUser;
  }

  User? get user => _user;

  Future<void> logout() async {
    await _auth?.signOut();
    _user = null;
    notifyListeners();
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    notifyListeners();
  }
}
