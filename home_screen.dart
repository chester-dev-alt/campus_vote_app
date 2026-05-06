import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../voting/ballot_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const VotingTab(),
    const PoliciesTab(),
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Vote'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.how_to_vote_outlined), selectedIcon: Icon(Icons.how_to_vote), label: 'Voting'),
          NavigationDestination(icon: Icon(Icons.policy_outlined), selectedIcon: Icon(Icons.policy), label: 'Policies'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==========================================
// 1. HOME DASHBOARD
// ==========================================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome, Student!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Stay updated with campus governance.', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    _buildStatCard('12', 'Active Elections', Icons.how_to_vote, Colors.blue),
                    const SizedBox(width: 16),
                    _buildStatCard('3', 'Pending', Icons.pending_actions, Colors.orange),
                  ],
                ),
                const SizedBox(height: 24),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Announcements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('See all', style: TextStyle(color: Colors.blue)),
                ]),
                const SizedBox(height: 12),
                _buildAnnouncementCard('SRC Elections 2026', 'Voting for Student Council starts today!', Icons.campaign, Colors.blue),
                _buildAnnouncementCard('Library Hours Extended', 'Open until midnight during finals.', Icons.library_books, Colors.green),
                _buildAnnouncementCard('New Policy Draft', 'Review the proposed WiFi policy.', Icons.description, Colors.purple),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String count, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(count, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _buildAnnouncementCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}

// ==========================================
// 2. VOTING TAB (FIREBASE CONNECTED)
// ==========================================
class VotingTab extends StatelessWidget {
  const VotingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'SRC/Union', icon: Icon(Icons.account_balance)),
              Tab(text: 'Faculty', icon: Icon(Icons.school)),
              Tab(text: 'Class Reps', icon: Icon(Icons.groups)),
              Tab(text: 'Clubs', icon: Icon(Icons.celebration)),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                ElectionsList(category: 'SRC'),
                ElectionsList(category: 'Faculty'),
                ElectionsList(category: 'Class Representative'),
                ElectionsList(category: 'Club'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ElectionsList extends StatelessWidget {
  final String category;
  const ElectionsList({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('elections')
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No active elections in $category'));
        }

        final elections = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: elections.length,
          itemBuilder: (context, index) {
            final election = elections[index].data() as Map<String, dynamic>;
            final electionId = elections[index].id;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.how_to_vote, color: Colors.blue),
                ),
                title: Text(election['title'] ?? 'Untitled Election', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(election['description'] ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BallotScreen(
                        position: election['title'] ?? 'Position',
                        category: category,
                        electionId: electionId,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
// ==========================================
// 3. POLICIES TAB
// ==========================================
class PoliciesTab extends StatefulWidget {
  const PoliciesTab({super.key});

  @override
  State<PoliciesTab> createState() => _PoliciesTabState();
}

class _PoliciesTabState extends State<PoliciesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _allPolicies = [
    {'id': 1, 'title': 'Academic Attendance Policy', 'category': 'Academic', 'date': 'Jan 15, 2026', 'status': 'Active', 'description': 'Students must maintain a minimum of 75% attendance in all courses to be eligible for final examinations.', 'fullText': '1. Attendance Requirement: Minimum 75% attendance is mandatory.\n2. Medical Leave: Students may apply for attendance relaxation with valid medical certificates.\n3. Consequences: Students falling below 75% will not be permitted to sit for exams without special approval.\n4. Tracking: Attendance is tracked weekly by department coordinators.'},
    {'id': 2, 'title': 'Library Usage & Extended Hours', 'category': 'Academic', 'date': 'Feb 02, 2026', 'status': 'Active', 'description': 'Library operating hours, borrowing limits, and rules for quiet zones and group study areas.', 'fullText': '1. Operating Hours: 8:00 AM - 10:00 PM (Mon-Sat), 10:00 AM - 6:00 PM (Sun).\n2. Borrowing Limit: Max 5 books for 14 days.\n3. Fines: \$0.50 per day overdue.\n4. Quiet Zones: Strict silence enforced in designated areas.\n5. Group Rooms: Bookable via student portal for up to 2 hours/day.'},
    {'id': 3, 'title': 'Student Welfare & Mental Health Support', 'category': 'Welfare', 'date': 'Mar 10, 2026', 'status': 'Active', 'description': 'Confidential counseling services, peer support programs, and emergency welfare assistance.', 'fullText': '1. Counseling: Free confidential sessions available Mon-Fri.\n2. Peer Support: Trained student volunteers available in all faculties.\n3. Emergency Fund: Financial assistance for students facing sudden hardship.\n4. Workshops: Monthly stress management and wellness workshops.\n5. Contact: welfare@campus.edu | Ext. 4500'},
    {'id': 4, 'title': 'Dormitory & Housing Regulations', 'category': 'Welfare', 'date': 'Nov 20, 2025', 'status': 'Active', 'description': 'Rules regarding guest visits, noise curfews, room inspections, and facility maintenance.', 'fullText': '1. Guest Policy: Visitors allowed 9 AM - 9 PM with registration.\n2. Quiet Hours: 10 PM - 7 AM daily.\n3. Inspections: Monthly safety and cleanliness checks.\n4. Maintenance: Report issues via housing portal within 24 hours.\n5. Prohibited: Open flames, unauthorized appliances, pets.'},
    {'id': 5, 'title': 'Tuition Fee & Payment Schedule', 'category': 'Finance', 'date': 'Aug 01, 2025', 'status': 'Active', 'description': 'Payment deadlines, installment plans, late fee policies, and scholarship disbursement rules.', 'fullText': '1. Deadline: Full payment due by start of each semester.\n2. Installments: 2-payment plan available with 5% admin fee.\n3. Late Fee: \$50 per week overdue.\n4. Scholarships: Disbursed within 14 days of verification.\n5. Refunds: Full refund if withdrawn within first 2 weeks.'},
    {'id': 6, 'title': 'Campus WiFi & Network Usage', 'category': 'General', 'date': 'Sep 15, 2025', 'status': 'Draft', 'description': 'Acceptable use policy, bandwidth limits, security requirements, and restricted content.', 'fullText': '1. Acceptable Use: Educational and personal use only.\n2. Bandwidth: Fair usage policy applies during peak hours.\n3. Security: WPA2-Enterprise required, no open networks.\n4. Restricted: P2P downloading, illegal streaming, hacking tools.\n5. Monitoring: Network traffic logged for security purposes.'},
    {'id': 7, 'title': 'Student Code of Conduct', 'category': 'Discipline', 'date': 'Jul 10, 2025', 'status': 'Active', 'description': 'Behavioral expectations, academic integrity, disciplinary procedures, and appeal processes.', 'fullText': '1. Integrity: Zero tolerance for plagiarism or cheating.\n2. Respect: Harassment, bullying, or discrimination strictly prohibited.\n3. Disciplinary Actions: Warning, probation, suspension, expulsion.\n4. Appeals: Written appeal to Student Affairs within 7 days.\n5. Review: Annual policy review by Student Council.'},
    {'id': 8, 'title': 'Event Organization & Approval', 'category': 'General', 'date': 'Oct 05, 2025', 'status': 'Active', 'description': 'Procedure for organizing campus events, venue booking, budget approval, and safety requirements.', 'fullText': '1. Proposal: Submit event form 30 days in advance.\n2. Venue: Book via campus portal, max 200 capacity indoors.\n3. Budget: Club funds require Treasurer approval.\n4. Safety: First aid kit and crowd control mandatory for >50 attendees.\n5. Cleanup: Organizers responsible for post-event cleanup.'},
  ];

  List<String> get _categories => ['All', 'Academic', 'Welfare', 'Finance', 'General', 'Discipline'];

  List<Map<String, dynamic>> get _filteredPolicies {
    return _allPolicies.where((policy) {
      final matchesCategory = _selectedCategory == 'All' || policy['category'] == _selectedCategory;
      final matchesSearch = policy['title'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          policy['description'].toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Academic':
        return Colors.blue;
      case 'Welfare':
        return Colors.green;
      case 'Finance':
        return Colors.orange;
      case 'General':
        return Colors.purple;
      case 'Discipline':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search policies...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() {}); })
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = category),
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _filteredPolicies.isEmpty
              ? const Center(child: Text('No policies found', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredPolicies.length,
            itemBuilder: (context, index) {
              final policy = _filteredPolicies[index];
              return _buildPolicyCard(context, policy);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyCard(BuildContext context, Map<String, dynamic> policy) {
    final Color categoryColor = _getCategoryColor(policy['category']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPolicyDetail(context, policy),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(policy['category'], style: TextStyle(color: categoryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  Text(policy['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Text(policy['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(policy['description'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: policy['status'] == 'Active' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      policy['status'],
                      style: TextStyle(
                        color: policy['status'] == 'Active' ? Colors.green : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showPolicyDetail(context, policy),
                    child: const Text('Read More', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPolicyDetail(BuildContext context, Map<String, dynamic> policy) {
    final Color categoryColor = _getCategoryColor(policy['category']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(height: 4, width: 40, margin: const EdgeInsets.only(top: 12), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: categoryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(policy['category'], style: TextStyle(color: categoryColor, fontSize: 12, fontWeight: FontWeight.bold))),
                      const Spacer(),
                      Text(policy['date'], style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(policy['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Text(policy['fullText'], style: const TextStyle(fontSize: 15, height: 1.6)),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Expanded(child: Text('For questions, contact the Student Affairs Office or submit feedback through the app.', style: TextStyle(color: Colors.blue))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. PROFILE TAB (UPDATED - WITH FIREBASE)
// ==========================================
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 🔹 Fetch User Data from Firestore
  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            _userData = doc.data()!;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading profile: $e');
      setState(() => _isLoading = false);
    }
  }

  // 🔹 Edit Profile Dialog
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userData['name'] ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .update({
                    'name': nameController.text.trim(),
                  });
                  _loadUserData(); // Refresh
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Profile Updated'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // 🔹 Coming Soon Dialog
  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('The $feature feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 🔹 Working Logout (GoRouter compatible)
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      context.go('/login');  // ✅ Use GoRouter instead of Navigator

    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = _userData['name'] ?? 'User';
    final email = user?.email ?? 'No Email';
    final studentId = _userData['studentId'] ?? '';
    final program = _userData['program'] ?? '';
    final year = _userData['year'] ?? 0;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ListView(
        children: [
          // 🔵 Header Section
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.blue),
                ),
                const SizedBox(height: 16),
                // ✅ Real Name from Firestore
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // ✅ Real Email from FirebaseAuth
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                // ✅ Student ID & Program from Firestore
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    studentId.isNotEmpty
                        ? '$program • Year $year'
                        : 'Update your profile',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 📂 Account Settings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                // ✅ Working Edit Profile
                _buildMenuItem(
                  context,
                  Icons.edit,
                  'Edit Profile',
                      () => _showEditProfileDialog(),
                ),
                _buildMenuItem(
                  context,
                  Icons.security,
                  'Security & Password',
                      () => _showComingSoon('Security'),
                ),
                _buildMenuItem(
                  context,
                  Icons.notifications,
                  'Notification Settings',
                      () => _showComingSoon('Notifications'),
                ),
                _buildMenuItem(
                  context,
                  Icons.language,
                  'Language',
                      () => _showComingSoon('Language'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 📂 App Preferences
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'App Preferences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  context,
                  Icons.dark_mode,
                  'Dark Mode',
                      () => _showComingSoon('Dark Mode'),
                ),
                _buildMenuItem(
                  context,
                  Icons.help_outline,
                  'Help & Support',
                      () => _showComingSoon('Help'),
                ),
                _buildMenuItem(
                  context,
                  Icons.info_outline,
                  'About App',
                      () => _showComingSoon('About'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 🚪 Working Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper Widget for Menu Items
  Widget _buildMenuItem(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}