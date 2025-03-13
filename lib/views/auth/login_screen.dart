import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      // Wrap in SingleChildScrollView to avoid bottom overflow
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Slightly smaller logo with extra spacing
              Center(
                child: Image.asset(
                  "lib/assets/images/logo.png",
                  width: 130,
                  height: 130,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(_emailController, "Email", Icons.email, false),
              const SizedBox(height: 15),
              _buildTextField(
                  _passwordController, "Password", Icons.lock, true),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      )),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() => _isLoading = true);
                        bool success = await userProvider.login(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                        setState(() => _isLoading = false);
                        if (success) {
                          Navigator.pushReplacementNamed(context, "/");
                        } else {
                          setState(() => _errorMessage = "Invalid credentials");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text("Login",
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                    ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/signup"),
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(color: Colors.orange, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.orange),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    );
  }
}
