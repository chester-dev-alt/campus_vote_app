import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BallotScreen extends StatefulWidget {
  final String position;
  final String category;
  final String electionId;

  const BallotScreen({super.key, required this.position, required this.category, required this.electionId});

  @override
  State<BallotScreen> createState() => _BallotScreenState();
}

class _BallotScreenState extends State<BallotScreen> {
  String? _selectedCandidateId;
  bool _hasVoted = false;

  @override
  void initState() {
    super.initState();
    _checkIfVoted();
  }

  Future<void> _checkIfVoted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final votedElections = List<String>.from(userDoc.data()?['hasVoted'] ?? []);
    if (mounted) {
      setState(() => _hasVoted = votedElections.contains(widget.electionId));
    }
  }

  Future<void> _submitVote() async {
    if (_selectedCandidateId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Record vote
      final voteRef = FirebaseFirestore.instance.collection('votes').doc();
      batch.set(voteRef, {
        'userId': user.uid,
        'electionId': widget.electionId,
        'candidateId': _selectedCandidateId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Increment candidate vote count
      final candidateRef = FirebaseFirestore.instance.collection('candidates').doc(_selectedCandidateId);
      batch.update(candidateRef, {'voteCount': FieldValue.increment(1)});

      // Mark user as voted
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      batch.update(userRef, {'hasVoted': FieldValue.arrayUnion([widget.electionId])});

      await batch.commit();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 48)),
                const SizedBox(height: 16),
                const Text('Vote Submitted Successfully!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Thank you for participating.', textAlign: TextAlign.center),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting vote: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasVoted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cast Your Vote'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              const Text('You have already voted', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Election: ${widget.position}', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cast Your Vote'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                Text(widget.position, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 4),
                Text(widget.category, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('candidates')
                  .where('electionId', isEqualTo: widget.electionId)
                  .orderBy('voteCount', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No candidates available'));
                }

                final candidates = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    final candidate = candidates[index].data() as Map<String, dynamic>;
                    final candidateId = candidates[index].id;
                    final isSelected = _selectedCandidateId == candidateId;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: isSelected ? 4 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 2 : 1),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _selectedCandidateId = candidateId),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
                                    child: Icon(Icons.person, size: 35, color: isSelected ? Colors.white : Colors.grey.shade700),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(candidate['name'] ?? 'Candidate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.blue : Colors.black87)),
                                        const SizedBox(height: 4),
                                        Text('${candidate['program'] ?? ''} • Year ${candidate['year'] ?? ''}', style: TextStyle(color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  ),
                                  Radio<String>(
                                    value: candidateId,
                                    groupValue: _selectedCandidateId,
                                    onChanged: (val) => setState(() => _selectedCandidateId = val),
                                    activeColor: Colors.blue,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(children: [Icon(Icons.policy, size: 16, color: Colors.blue), SizedBox(width: 8), Text('Manifesto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]),
                                    const SizedBox(height: 8),
                                    Text(candidate['manifesto'] ?? '', style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))]),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedCandidateId == null ? null : _submitVote,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(_selectedCandidateId == null ? 'Select a Candidate' : 'Submit Vote', style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}