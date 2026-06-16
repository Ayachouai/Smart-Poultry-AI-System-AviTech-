import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerProfilePage extends StatefulWidget {
  const FarmerProfilePage({super.key});
  @override
  _FarmerProfilePageState createState() => _FarmerProfilePageState();
}

class _FarmerProfilePageState extends State<FarmerProfilePage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController chickenNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        fullNameController.text = data['fullName'] ?? '';
        emailController.text = data['email'] ?? '';
        addressController.text = data['address'] ?? '';
        locationController.text = data['location'] ?? '';
        chickenNumberController.text = data['chickenCount']?.toString() ?? '';
      } else {
        emailController.text =
            FirebaseAuth.instance.currentUser?.email ?? 'No email';
      }
    }
  }

  Future<void> _updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      final userData = {
        'fullName': fullNameController.text.trim(),
        'email': user.email,
        'address': addressController.text.trim(),
        'location': locationController.text.trim(),
        'chickenCount': int.tryParse(chickenNumberController.text.trim()) ?? 0,
        'updatedAt': DateTime.now(),
      };

      final doc = await userRef.get();
      if (doc.exists) {
        await userRef.update(userData);
      } else {
        await userRef.set(userData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile saved successfully')),
      );
    }
  }

  Future<void> _deleteUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;

      try {
        // Tentative directe de suppression du compte
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          final password = await _promptPasswordDialog();
          if (password == null || password.isEmpty) return;

          final cred = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );

          await user.reauthenticateWithCredential(cred);
          await user.delete(); // Suppression après re-auth
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : ${e.message}')),
          );
          return;
        }
      }

      // Supprimer les données Firestore après suppression du compte
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compte supprimé avec succès')),
      );

      Navigator.of(context).popUntil((route) => route.isFirst); // Redirection
    }
  }

  Future<String?> _promptPasswordDialog() async {
    String password = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Vérification du mot de passe"),
        content: TextField(
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(labelText: "Mot de passe"),
          onChanged: (value) => password = value,
        ),
        actions: [
          TextButton(
            child: Text("Annuler"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Confirmer"),
            onPressed: () => Navigator.pop(context, password),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmation"),
        content: Text("Voulez-vous vraiment supprimer votre compte ?"),
        actions: [
          TextButton(
            child: Text("Annuler"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text("Supprimer", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteUserData();
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.green.shade400),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/chiken4.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.home, color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Welcome to AviTech",
                        style: GoogleFonts.lobster(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.green.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                'assets/chiken5.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: _updateUserData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      side: BorderSide(
                                        color: Colors.green.shade400,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _confirmDelete,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      side: BorderSide(
                                        color: Colors.green.shade400,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        _buildTextField('Full Name', fullNameController),
                        _buildTextField(
                          'Email',
                          emailController,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: true,
                        ),
                        _buildTextField('Address', addressController),
                        _buildTextField('Location', locationController),
                        _buildTextField(
                          'Number of Chickens',
                          chickenNumberController,
                          keyboardType: TextInputType.number,
                        ),
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
