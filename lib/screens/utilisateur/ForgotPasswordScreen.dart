import 'package:flutter/material.dart';
import 'package:swapngive/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  void _sendResetPasswordEmail() async {
    try {
      await _authService.resetPassword(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-mail de réinitialisation envoyé!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD9A9A9),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          color: Colors.white,
          onPressed: (){
            Navigator.pop(context);
          },
        ),    
        title: Text("Mot de Passe Oublié", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),)
        ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entrez votre e-mail pour recevoir un lien de réinitialisation.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendResetPasswordEmail,
              child: Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
}
