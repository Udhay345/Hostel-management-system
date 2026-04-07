import 'package:flutter/material.dart';

class MessPollScreen extends StatefulWidget {
  const MessPollScreen({super.key});

  @override
  State<MessPollScreen> createState() => _MessPollScreenState();
}

class _MessPollScreenState extends State<MessPollScreen> {
  String? _selectedOption;
  final _feedbackController = TextEditingController();
  bool _hasVoted = false;
  bool _isLoading = false;

  // Current poll data (in real app, this would come from admin)
  final Map<String, dynamic> _currentPoll = {
    'title': 'Rate this week\'s mess dinner',
    'options': [
      'Excellent - 5 stars',
      'Very Good - 4 stars',
      'Good - 3 stars',
      'Average - 2 stars',
      'Poor - 1 star',
    ],
  };

  void _submitVote() {
    if (_selectedOption != null) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _hasVoted = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vote submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitFeedback() {
    if (_feedbackController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 1), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _feedbackController.clear();
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mess Poll & Feedback',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.poll, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Current Poll',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentPoll['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_hasVoted) ...[
                    ..._currentPoll['options'].map<Widget>((option) {
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: _selectedOption,
                        onChanged: (value) {
                          setState(() {
                            _selectedOption = value;
                          });
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitVote,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Submit Vote'),
                      ),
                    ),
                  ] else ...[
                    const Card(
                      color: Colors.green,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'You have already voted!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.feedback, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        'Additional Feedback',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _feedbackController,
                    decoration: const InputDecoration(
                      labelText: 'Share your thoughts about the mess food...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitFeedback,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Submit Feedback'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Poll Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Polls are updated weekly'),
                  Text('• Your vote helps improve mess quality'),
                  Text('• Feedback is reviewed by admin'),
                  Text('• Results are shared with mess committee'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
} 