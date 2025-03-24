import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Add this package
import '../../providers/user_provider.dart';
import '../../models/user.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];
  bool _isLoading = false;
  String? _errorMessage;

  File? _profileImage; // New: to hold the selected image file
  final ImagePicker _picker = ImagePicker(); // New: image picker instance

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  bool _validateEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _validatePhone(String phone) {
    final RegExp phoneRegex = RegExp(r'^\d{8}$');
    return phoneRegex.hasMatch(phone);
  }

  bool _validatePassword(String password) {
    final RegExp passwordRegex =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  void _signUp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String dob = _dobController.text.trim();
    String? gender = _selectedGender;

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        dob.isEmpty ||
        gender == null) {
      setState(() => _errorMessage = "All fields are required.");
      return;
    }

    if (!_validateEmail(email)) {
      setState(() => _errorMessage = "Invalid email format.");
      return;
    }

    if (!_validatePhone(phone)) {
      setState(() => _errorMessage = "Phone number must be 8 digits.");
      return;
    }

    if (!_validatePassword(password)) {
      setState(() => _errorMessage =
          "Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, a number, and a special character.");
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = "Passwords do not match.");
      return;
    }

    DateTime birthDate = DateFormat('yyyy-MM-dd').parse(dob);
    int age = DateTime.now().year - birthDate.year;
    if (DateTime.now().month < birthDate.month ||
        (DateTime.now().month == birthDate.month &&
            DateTime.now().day < birthDate.day)) {
      age--;
    }

    if (age < 15) {
      setState(() => _errorMessage = "You must be at least 15 years old.");
      return;
    }

    // Create a new user including the profile image path (if selected)
    User newUser = User(
      id: 0,
      name: name,
      email: email,
      phoneNumber: phone,
      password: password,
      gender: gender,
      dateOfBirth: dob,
      profileImage: _profileImage?.path ?? '', // Save file path
    );

    setState(() => _isLoading = true);
    bool success = await userProvider.register(newUser);
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => _errorMessage = "Failed to register. Try again.");
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
      obscureText: obscureText,
      readOnly: readOnly,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Wrap in SingleChildScrollView
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile image uploader
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white24,
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.camera_alt,
                        size: 40, color: Colors.white70)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            // Logo
            const SizedBox(height: 30),
            _buildTextField(controller: _nameController, label: "Full Name"),
            const SizedBox(height: 12),
            _buildTextField(controller: _emailController, label: "Email"),
            const SizedBox(height: 12),
            _buildTextField(controller: _phoneController, label: "Phone"),
            const SizedBox(height: 12),
            // Dropdown for Gender with a label
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: "Gender",
                labelStyle:
                    const TextStyle(color: Colors.white70, fontSize: 14),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: _genders
                  .map((g) => DropdownMenuItem(
                      value: g,
                      child:
                          Text(g, style: const TextStyle(color: Colors.white))))
                  .toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 12),
            _buildTextField(
                controller: _dobController,
                label: "Date of Birth (YYYY-MM-DD)",
                readOnly: true,
                onTap: () => _selectDate(context)),
            const SizedBox(height: 12),
            _buildTextField(
                controller: _passwordController,
                label: "Password",
                obscureText: true),
            const SizedBox(height: 12),
            _buildTextField(
                controller: _confirmPasswordController,
                label: "Confirm Password",
                obscureText: true),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    )),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign Up",
                        style: TextStyle(fontSize: 16, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
