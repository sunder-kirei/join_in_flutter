import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  static const routeName = "/auth";

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _focusNode = FocusNode();
  final _key = GlobalKey<FormState>();
  String? email;
  String? password;
  bool isLogin = false;
  bool isLoading = false;

  Future<void> _signUp() async {
    setState(() {
      isLoading = true;
    });
    try {
      final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      final uid = user.user?.uid;
      await FirebaseFirestore.instance.collection("users").doc(uid).set(
        {
          "email": user.user?.email,
          "uid": user.user?.uid,
        },
      );
    } catch (err) {
      final errorMessage = err.toString().split(' ').sublist(1).join(' ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _signIn() async {
    setState(() {
      isLoading = true;
    });
    FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email!,
      password: password!,
    );
    setState(() {
      isLoading = false;
    });
    return;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin ? "Welcome Back" : "Welcome to JoinIN!",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isLogin ? "Been a while!" : "Let's set you up!",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 40),
                      AutofillGroup(
                        child: Form(
                          key: _key,
                          child: Column(
                            children: [
                              TextFormField(
                                autofillHints: const [AutofillHints.email],
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return "Please enter a valid email address.";
                                  }
                                  return null;
                                },
                                onSaved: (newValue) => email = newValue,
                                decoration: const InputDecoration(
                                  hintText: "Email Address",
                                ),
                                onEditingComplete: () {
                                  FocusScope.of(context).nextFocus();
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                decoration: const InputDecoration(
                                  hintText: "Password",
                                ),
                                autofillHints: const [AutofillHints.password],
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return "Please enter a valid password.";
                                  }
                                  if ((value?.length ?? 0) < 6) {
                                    return "Password must be atleast 6 characters long.";
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  password = newValue;
                                  isLogin ? _signIn() : _signUp();
                                },
                                focusNode: _focusNode,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: true,
                                onEditingComplete: () {
                                  final isValid =
                                      _key.currentState?.validate() ?? false;
                                  if (isValid) {
                                    _key.currentState?.save();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("Forgot Password?"),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () {
                            final isValid =
                                _key.currentState?.validate() ?? false;
                            if (isValid) {
                              _key.currentState?.save();
                            }
                          },
                          style: Theme.of(context).elevatedButtonTheme.style,
                          child: Text(isLogin ? "Sign In" : "Sign Up"),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLogin
                                ? "Don't have an account?"
                                : "Already a member?",
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            child: Text(isLogin ? "Sign Up" : "Login"),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
