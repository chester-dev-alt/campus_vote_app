import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewResultsScreen extends StatefulWidget {
  const ViewResultsScreen({super.key});

  @override
  State<ViewResultsScreen> createState() => _ViewResultsScreenState();
}

class _ViewResultsScreenState extends State<ViewResultsScreen> {
  bool _isProcessing = false;

  // 🗑️ Delete Election
  Future<void> _confirmDeleteElection(BuildContext context, String electionId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Election?'),
        content: Text('Are you sure you want to delete "$title"? This will also remove all associated candidates and votes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessing = true);
      try {
        // Delete election doc
        await FirebaseFirestore.instance.collection('elections').doc(electionId).delete();

        // Delete all candidates for this election
        final candidates = await FirebaseFirestore.instance
            .collection('candidates')
            .where('electionId', isEqualTo: electionId)
            .get();

        for (var doc in candidates.docs) {
          await doc.reference.delete();
        }

        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Election deleted successfully'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // ✏️ Edit Election Dialog
  void _showEditElectionDialog(BuildContext context, String electionId, Map<String, dynamic> election) {
    final titleController = TextEditingController(text: election['title'] ?? '');
    final categoryController = TextEditingController(text: election['category'] ?? '');
    final descController = TextEditingController(text: election['description'] ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Election'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category/Position', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                setState(() => _isProcessing = true);
                try {
                  await FirebaseFirestore.instance.collection('elections').doc(electionId).update({
                    'title': titleController.text.trim(),
                    'category': categoryController.text.trim(),
                    'description': descController.text.trim(),
                  });
                  if (mounted) {
                    setState(() => _isProcessing = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Election updated'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() => _isProcessing = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
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

  // 🗑️ Delete Candidate
  Future<void> _confirmDeleteCandidate(BuildContext context, String candidateId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Candidate?'),
        content: Text('Remove "$name" from this election?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('candidates').doc(candidateId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Candidate removed'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Election Results'),
        actions: [
          if (_isProcessing) const Padding(padding: EdgeInsets.all(16), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('elections').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No elections yet'));
          }

          final elections = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: elections.length,
            itemBuilder: (context, index) {
              final election = elections[index].data() as Map<String, dynamic>;
              final electionId = elections[index].id;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(election['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${election['category'] ?? ''} • Total Votes: ${election['totalVotes'] ?? 0}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditElectionDialog(context, electionId, election),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteElection(context, electionId, election['title'] ?? 'Untitled'),
                      ),
                    ],
                  ),
                  children: [
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('candidates')
                          .where('electionId', isEqualTo: electionId)
                          .orderBy('voteCount', descending: true)
                          .get(),
                      builder: (context, candidateSnapshot) {
                        if (!candidateSnapshot.hasData) return const SizedBox();

                        final candidates = candidateSnapshot.data!.docs;

                        // 🔢 Calculate total votes dynamically
                        int totalVotes = 0;
                        for (var doc in candidates) {
                          final data = doc.data() as Map<String, dynamic>;
                          totalVotes += (data['voteCount'] as int? ?? 0);
                        }

                        return Column(
                          children: candidates.map((doc) {
                            final candidate = doc.data() as Map<String, dynamic>;
                            final candidateId = doc.id;
                            final votes = candidate['voteCount'] as int? ?? 0;
                            final double percentageVal = totalVotes > 0 ? (votes / totalVotes) * 100 : 0.0;
                            final percentage = percentageVal.toStringAsFixed(1);

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: votes > 0 ? Colors.green.shade100 : Colors.grey.shade200,
                                child: Text('#${candidates.indexOf(doc) + 1}',
                                    style: TextStyle(color: votes > 0 ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(candidate['name'] ?? 'Unknown'),
                              subtitle: Text('${candidate['program'] ?? ''}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('$votes votes', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('$percentage%', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                    onPressed: () => _confirmDeleteCandidate(context, candidateId, candidate['name'] ?? 'Candidate'),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
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