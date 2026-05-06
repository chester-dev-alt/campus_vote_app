import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCandidateScreen extends StatefulWidget {
  const AddCandidateScreen({super.key});

  @override
  State<AddCandidateScreen> createState() => _AddCandidateScreenState();
}

class _AddCandidateScreenState extends State<AddCandidateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _manifestoController = TextEditingController();
  final _programController = TextEditingController();
  String _selectedElection = '';
  int _year = 1;
  List<Map<String, dynamic>> _elections = [];

  @override
  void initState() {
    super.initState();
    _loadElections();
  }

  Future<void> _loadElections() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('elections')
        .where('isActive', isEqualTo: true)
        .get();
    setState(() {
      _elections = snapshot.docs
          .map((doc) => {'id': doc.id, 'title': doc['title']})
          .toList();
      if (_elections.isNotEmpty) {
        _selectedElection = _elections.first['id'];
      }
    });
  }

  Future<void> _saveCandidate() async {
    if (_formKey.currentState!.validate() && _selectedElection.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('candidates').add({
          'electionId': _selectedElection,
          'name': _nameController.text,
          'manifesto': _manifestoController.text,
          'program': _programController.text,
          'year': _year,
          'voteCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('✅ Candidate added successfully!'),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Add Candidate')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_elections.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No active elections. Create one first!',
                      style: TextStyle(color: Colors.orange)),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedElection.isNotEmpty ? _selectedElection : null,
                  decoration: const InputDecoration(
                      labelText: 'Election', border: OutlineInputBorder()),
                  items: _elections.isEmpty
                      ? []
                      : _elections
                      .map((e) => DropdownMenuItem<String>(
                      value: e['id'] as String,
                      child: Text(e['title'] as String)))
                      .toList(),
                  onChanged: _elections.isEmpty
                      ? null
                      : (val) => setState(() => _selectedElection = val!),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Candidate Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _programController,
                decoration: const InputDecoration(
                    labelText: 'Program/Department', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _year,
                decoration: const InputDecoration(
                    labelText: 'Year of Study', border: OutlineInputBorder()),
                items: [1, 2, 3, 4, 5]
                    .map((y) => DropdownMenuItem(value: y, child: Text('Year $y')))
                    .toList(),
                onChanged: (val) => setState(() => _year = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _manifestoController,
                maxLines: 5,
                decoration: const InputDecoration(
                    labelText: 'Manifesto',
                    hintText: 'What will you do if elected?',
                    border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveCandidate,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Add Candidate',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}