import 'package:flutter/material.dart';

class RegisteredUsersScreen extends StatelessWidget {
  const RegisteredUsersScreen({super.key});

  Widget _buildUserItem(BuildContext context, String name, String phone, String id) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.teal.withOpacity(0.1),
            child: Text(name[0], style: const TextStyle(color: Colors.teal)),
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("ID: $id • Phone: $phone"),
          trailing: OutlinedButton.icon(
            onPressed: () { debugPrint('Delete clicked for $name'); },
            icon: const Icon(Icons.delete_outline, size: 20),
            label: const Text("Delete Account"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Registered Users Database'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: <Widget>[
                _buildUserItem(context, 'Sarah Ahmed', '0933333333', 'USR-101'),
                _buildUserItem(context, 'Mohammed Ali', '0945444444', 'USR-102'),
                _buildUserItem(context, 'Lina Othman', '0911111111', 'USR-103'),
                _buildUserItem(context, 'Kareem Jaber', '0977777777', 'USR-104'),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//home: RegisteredUsersScreen(),