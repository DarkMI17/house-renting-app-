import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SignUpPage(),
  ));
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  bool _isProfileImageSelected = false;
  bool _isIdImageSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Create Account"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        const SizedBox(height: 10),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isProfileImageSelected = !_isProfileImageSelected;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Simulating Profile Photo Selection...')),
                          );
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: _isProfileImageSelected ? Colors.blue[100] : Colors.grey[200],
                              backgroundImage: _isProfileImageSelected

                                  ? const NetworkImage('https://via.placeholder.com/150')
                                  : null,
                              child: !_isProfileImageSelected
                                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  _isProfileImageSelected ? Icons.edit : Icons.add_a_photo,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      children: [
                    Expanded(
                    child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "First Name",
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>value!.isEmpty ? 'Required' : null,
                    ),
                    ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Last Name",
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),


                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'Enter phone number' : null,
                    ),
                    const SizedBox(height: 20),


                    TextFormField(
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'Enter password' : null,
                    ),
                    const SizedBox(height: 25),


                    const Text(
                      "Upload ID Card",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            _isIdImageSelected = !_isIdImageSelected;
                          });
                        },
                        child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _isIdImageSelected ? Colors.blue[50] : Colors.grey[100],
                              border: Border.all(
                                color: _isIdImageSelected ? Colors.blue : Colors.grey,
                                style: BorderStyle.solid,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _isIdImageSelected
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                              Icon(Icons.check_circle, size: 50, color: Colors.green),
                              SizedBox(height: 10),Text("ID Image Selected",
                                    style: TextStyle(
                                        color: Colors.green, fontWeight: FontWeight.bold)),
                                Text("(Tap to change)", style: TextStyle(color: Colors.grey)),
                              ],
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.cloud_upload_outlined,
                                    size: 50, color: Colors.blue),
                                SizedBox(height: 10),
                                Text("Tap to upload ID photo"),
                              ],
                            ),
                        ),
                    ),
                          const SizedBox(height: 40),

                          SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (!_isProfileImageSelected || !_isIdImageSelected) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please upload both Profile and ID photos'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Processing Sign Up...')),
                                    );
                                  }
                                }
                              },
                              child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                    ),
                ),
            ),
        ),
    );
  }
}
//home: SignUpPage (),