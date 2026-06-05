import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Registered Users'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Provider.of<AppProvider>(context, listen: false).getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada pengguna terdaftar.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final String username = user['username'] ?? 'No Name';
              final String email = user['email'] ?? 'No Email';
              final String role = user['role'] ?? 'user';
              final String id = user['id'] ?? 'N/A';
              
              DateTime? regDate;
              if (user['createdAt'] != null) {
                try {
                  regDate = DateTime.parse(user['createdAt']);
                } catch (_) {}
              }

              final bool isAdmin = role.toLowerCase() == 'admin';

              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isAdmin 
                          ? Colors.blue.withOpacity(0.1) 
                          : Colors.green.withOpacity(0.1),
                      child: Icon(
                        isAdmin ? Icons.admin_panel_settings : Icons.person,
                        color: isAdmin ? Colors.blue : Colors.green,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isAdmin 
                                      ? Colors.blue.withOpacity(0.1) 
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isAdmin ? Colors.blue : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Divider(color: Theme.of(context).dividerColor, height: 1),
                          const SizedBox(height: 8),
                          Text(
                            'ID: $id',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          if (regDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Terdaftar: ${DateFormat('dd MMM yyyy, HH:mm').format(regDate)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
