import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:operationcore2/providers/auth_provider.dart';
import 'package:operationcore2/utils/auto_updater.dart';
import 'package:shared_preferences/shared_preferences.dart';

String hashPassword(String password) {
  return BCrypt.hashpw(password, BCrypt.gensalt());
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          backgroundCyber(),
          Align(alignment: AlignmentGeometry.center, child: body()),
        ],
      ),
    );
  }
}

class body extends ConsumerStatefulWidget {
  const body({super.key});

  @override
  ConsumerState<body> createState() => _bodyState();
}

class _bodyState extends ConsumerState<body> {
  bool obscure = true;
  bool check = false;
  final TextEditingController password = TextEditingController();
  final TextEditingController username = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AutoUpdater.checkForUpdates(context);
    });
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedUsername = prefs.getString('saved_username');
    final String? savedPassword = prefs.getString('saved_password');
    final bool? savedCheck = prefs.getBool('remember_me');

    if (savedCheck == true && savedUsername != null && savedPassword != null) {
      if (mounted) {
        setState(() {
          username.text = savedUsername;
          password.text = savedPassword;
          check = true;
        });
        
        // Auto-login logic
        _handleLogin(savedUsername, savedPassword);
      }
    }
  }

  Future<void> _handleLogin(String u, String p) async {
    // Optional: add a small delay to let UI build
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    final success = await ref.read(authProvider.notifier).login(u, p);
    if (success) {
      Get.offAllNamed("/home");
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (check) {
      await prefs.setString('saved_username', username.text);
      await prefs.setString('saved_password', password.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          logo(),
          SizedBox(height: 30),
          textBold("Secure Login"),
          SizedBox(height: 10),
          textRegular("Enter your credentials to access the monitor"),
          SizedBox(height: 10),
          _card(
            width: 400,
            padding: 30,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  cyberTextField(
                    controller: username,
                    hint: "Enter your email",
                    label: "Username/Email",
                    prefixIcon: Icons.alternate_email,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username/Email tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  cyberTextField(
                    controller: password,
                    label: "Password",
                    hint: "Enter your password",
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: Icons.visibility_outlined,
                    obscure: obscure,
                    onSuffixTap: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Checkbox(
                          checkColor: Color(0xff137FEC),
                          activeColor: Color(0xff137FEC).withOpacity(.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: Color(0xff137FEC).withOpacity(.5),
                          ),
                          value: check,
                          onChanged: (bool? newValue) {
                            setState(() {
                              check = newValue ?? false;
                            });
                          },
                        ),
                        textremember("Remember this device"),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff137FEC),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 22,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      // final String hashed = BCrypt.hashpw(
                      //   password.text,
                      //   BCrypt.gensalt(logRounds: 12),
                      // );

                      // print("Hasil Hash: $hashed");
                      if (!_formKey.currentState!.validate()) return;

                      final success = await ref
                          .read(authProvider.notifier)
                          .login(username.text, password.text);

                      if (success) {
                        await _saveCredentials();
                        Get.toNamed("/home");
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Username atau password salah"),
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Sign In",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.login, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _card({
  double? width,
  double? height,
  required double padding,
  required Widget child,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Color(0xff101922).withOpacity(.6),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xff137FEC).withOpacity(.2), width: 1),
    ),
    padding: EdgeInsetsDirectional.all(padding),
    child: child,
  );
}

class logo extends StatelessWidget {
  const logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xff137FEC).withOpacity(.1),
        border: Border.all(color: Color(0xff137FEC).withOpacity(.5), width: 1),
      ),
      padding: EdgeInsets.all(20),
      child: Icon(
        Icons.stacked_line_chart_rounded,
        color: Color(0xff137FEC),
        size: 27,
      ),
    );
  }
}

Widget cyberTextField({
  required String label,
  required String hint,
  required IconData prefixIcon,
  IconData? suffixIcon,
  bool obscure = false,
  TextEditingController? controller,
  VoidCallback? onSuffixTap,
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xff9CA3AF), fontSize: 16),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xff6B7280)),

          /// icon kiri
          prefixIcon: Icon(prefixIcon, color: const Color(0xff9CA3AF)),

          /// icon kanan
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: obscure
                      ? Icon(suffixIcon, color: const Color(0xff9CA3AF))
                      : Icon(
                          Icons.visibility_off,
                          color: const Color(0xff9CA3AF),
                        ),
                )
              : null,

          filled: true,
          fillColor: const Color(0xff071A2B),

          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff1E40AF)),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff1E40AF)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff3B82F6), width: 2),
          ),

          errorStyle: const TextStyle(color: Color(0xffF87171)),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xffF87171), width: 1.5),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xffF87171), width: 2),
          ),
        ),
        validator: validator,
      ),
    ],
  );
}

Widget textBold(String label) {
  return Text(
    label,
    style: GoogleFonts.inter(
      color: Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget textRegular(String label) {
  return Text(
    label,
    style: GoogleFonts.inter(color: Color(0xff94A3B8), fontSize: 16),
  );
}

Widget textremember(String label) {
  return Text(
    label,
    style: GoogleFonts.inter(color: Color(0xff94A3B8), fontSize: 14),
  );
}

Widget backgroundCyber() {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff071A2B), Color(0xff02101D), Color(0xff010A14)],
        stops: [0.0, 0.5, 1.0],
      ),
    ),
    child: Stack(
      children: [
        /// glow kiri
        Positioned(
          left: -200,
          top: -100,
          child: Container(
            width: 600,
            height: 600,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color.fromARGB(120, 0, 140, 255), Colors.transparent],
                radius: 0.6,
              ),
            ),
          ),
        ),

        /// glow tengah
        Positioned(
          child: Center(
            child: Container(
              width: 500,
              height: 500,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color.fromARGB(90, 0, 90, 180), Colors.transparent],
                  radius: 0.7,
                ),
              ),
            ),
          ),
        ),

        /// glow kanan bawah
        Positioned(
          right: -150,
          bottom: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color.fromARGB(100, 0, 120, 255), Colors.transparent],
                radius: 0.7,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
