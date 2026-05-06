import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'create_election_screen.dart';
import 'view_results_screen.dart';
import 'manage_candidates_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Admin Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.red.shade50,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.red.shade700,
                  child: const Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? 'Admin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                ),
                const Text('Administrator', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _buildStatCard('Active Elections', Icons.how_to_vote, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Total Voters', Icons.people, Colors.green)),
              ],
            ),
          ),

          // Menu Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  context,
                  'Create Election',
                  Icons.add_circle_outline,
                  Colors.blue,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateElectionScreen())),
                ),
                _buildMenuCard(
                  context,
                  'Manage Candidates',
                  Icons.people_outline,
                  Colors.green,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCandidatesScreen())),
                ),
                _buildMenuCard(
                  context,
                  'View Results',
                  Icons.bar_chart,
                  Colors.purple,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewResultsScreen())),
                ),
                _buildMenuCard(
                  context,
                  'Active Elections',
                  Icons.list_alt,
                  Colors.orange,
                      () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, IconData icon, Color color) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('elections').where('isActive', isEqualTo: true).get(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5)],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text('$count', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}