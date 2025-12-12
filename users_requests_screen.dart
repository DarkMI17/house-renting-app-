import 'package:flutter/material.dart';

class UserRequestsScreen extends StatelessWidget {
  const UserRequestsScreen({super.key});

  void _showIDImageDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ID Image - $userName'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'ID image',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
                const SizedBox(height: 10),

                // استخدام Placeholder Widget لعرض صورة وهمية
                Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                        Icons.photo_size_select_actual_outlined,
                        size: 80,
                        color: Colors.grey[600]
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequestItem(BuildContext context, String name, String phone, String id) {
    return Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  child: Text(
                    name[0],
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ),
                title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                subtitle: Text("ID: $id • $phone"),


                trailing: SizedBox(
                  width: 250,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                  IconButton(
                  icon: const Icon(Icons.perm_identity, color: Colors.blueGrey),
                  tooltip: 'View ID Photo',
                  onPressed: () => _showIDImageDialog(context, name),
                ),

                const SizedBox(width: 10),

                SizedBox(
                    width: 150,
                    child: Row(
                        children: [
                    Expanded(
                    child: ElevatedButton(
                    onPressed: () { debugPrint('Accept clicked for $name'); },
                    child: const Text("Accept", style: TextStyle(fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8)
                    ),
                    ),
                    ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () { debugPrint('Reject clicked for $name'); }, 
                              child: const Text("Reject", style: TextStyle(fontSize: 15)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8)
                              ),
                            ),
                          ),
                        ],
                    ),
                ),
                      ],
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
        title: const Text('Pending User Requests'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), 
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: <Widget>[
                // البيانات الوهمية
                _buildRequestItem(context, 'Sarah Ahmed', '0933333333', 'REQ-101'),
                _buildRequestItem(context, 'Mohammed Ali', '0945444444', 'REQ-102'),
                _buildRequestItem(context, 'Lina Othman', '0911111111', 'REQ-103'),
                _buildRequestItem(context, 'Kareem Jaber', '0977777777', 'REQ-104'),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// home: UserRequestsScreen(),

