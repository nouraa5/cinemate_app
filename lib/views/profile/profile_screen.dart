import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _genderController;
  late TextEditingController _dobController;
  File? _newProfileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController(text: user?.phoneNumber);
    _genderController = TextEditingController(text: user?.gender);
    _dobController = TextEditingController(text: user?.dateOfBirth);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _newProfileImage = null;
      }
    });
  }

  Future<void> _pickNewProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;
    User updatedUser = currentUser.copyWith(
      name: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      gender: _genderController.text,
      dateOfBirth: _dobController.text,
      profileImage: _newProfileImage != null
          ? _newProfileImage!.path
          : currentUser.profileImage,
    );
    bool success = await userProvider.updateUser(updatedUser);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile.')),
      );
    }
    setState(() {
      _isEditing = false;
      _newProfileImage = null;
    });
  }

  /// Builds a profile avatar wrapped in an orange border.
  /// When [editable] is true, the avatar is tappable to update the image.
  Widget _buildProfileAvatar(User user, {bool editable = false}) {
    Widget avatar = CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[800],
      backgroundImage: _newProfileImage != null
          ? FileImage(_newProfileImage!)
          : (user.profileImage != null && user.profileImage!.isNotEmpty)
              ? FileImage(File(user.profileImage!))
              : null,
      child: (user.profileImage == null || user.profileImage!.isEmpty) &&
              _newProfileImage == null
          ? Icon(Icons.person, size: 60, color: Colors.white)
          : null,
    );
    Widget borderedAvatar = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: avatar,
    );
    if (editable) {
      return GestureDetector(
        onTap: _pickNewProfileImage,
        child: borderedAvatar,
      );
    } else {
      return borderedAvatar;
    }
  }

  Widget _buildReadOnlyView(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProfileAvatar(user, editable: false),
        SizedBox(height: 20),
        // Name
        Text(
          _nameController.text,
          style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                    blurRadius: 2, color: Colors.black45, offset: Offset(1, 1))
              ]),
        ),
        SizedBox(height: 5),
        // Email
        Text(
          _emailController.text,
          style: TextStyle(color: Colors.white70, fontSize: 16, shadows: [
            Shadow(blurRadius: 2, color: Colors.black45, offset: Offset(1, 1))
          ]),
        ),
        SizedBox(height: 20),
        Divider(color: Colors.white24),
        // Details in a Card for a modern look
        Card(
          color: Colors.grey[900],
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.phone, color: Colors.white),
                title: Text(
                  _phoneController.text.isNotEmpty
                      ? _phoneController.text
                      : 'No phone number',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Divider(color: Colors.white24, height: 1),
              ListTile(
                leading: Icon(Icons.cake, color: Colors.white),
                title: Text(
                  _dobController.text.isNotEmpty
                      ? _dobController.text
                      : 'No birth date',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Divider(color: Colors.white24, height: 1),
              ListTile(
                leading: Icon(Icons.person_outline, color: Colors.white),
                title: Text(
                  _genderController.text.isNotEmpty
                      ? _genderController.text
                      : 'No gender specified',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(User user) {
    return Column(
      children: [
        _buildProfileAvatar(user, editable: true),
        SizedBox(height: 20),
        _buildTextField(_nameController, 'Name'),
        _buildTextField(_emailController, 'Email', isEmail: true),
        _buildTextField(_phoneController, 'Phone Number'),
        _buildTextField(_genderController, 'Gender'),
        _buildTextField(_dobController, 'Date of Birth'),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Save', style: TextStyle(color: Colors.black)),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _newProfileImage = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
            child: Text('No user information available.',
                style: TextStyle(color: Colors.white))),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Profile',
            style: TextStyle(color: Colors.white, shadows: [
              Shadow(blurRadius: 2, color: Colors.black45, offset: Offset(1, 1))
            ])),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(icon: Icon(Icons.edit), onPressed: _toggleEditMode)
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _isEditing ? _buildEditForm(user) : _buildReadOnlyView(user),
      ),
    );
  }
}
