import 'package:flutter/material.dart';

class PostWeeklyPollScreen extends StatefulWidget {
  const PostWeeklyPollScreen({super.key});

  @override
  State<PostWeeklyPollScreen> createState() => _PostWeeklyPollScreenState();
}

class _PostWeeklyPollScreenState extends State<PostWeeklyPollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isLoading = false;

  void _addOption() {
    if (_optionControllers.length < 6) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 3) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  void _submitPoll() {
    if (_formKey.currentState!.validate()) {
      // Check if all options are filled
      bool allOptionsFilled = _optionControllers.every((controller) => 
        controller.text.trim().isNotEmpty);
      
      if (!allOptionsFilled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all poll options'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 1), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weekly poll posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        // Reset form
        _titleController.clear();
        for (var controller in _optionControllers) {
          controller.clear();
        }
        // Reset to 3 options
        while (_optionControllers.length > 3) {
          _optionControllers.removeLast().dispose();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Post Weekly Poll',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Poll Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.poll),
                hintText: 'e.g., Rate this week\'s mess dinner',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter poll title';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Poll Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_optionControllers.length}/6',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(_optionControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _optionControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Option ${index + 1}',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.radio_button_unchecked),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter option ${index + 1}';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_optionControllers.length > 3) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeOption(index),
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        tooltip: 'Remove option',
                      ),
                    ],
                  ],
                ),
              );
            }),
            if (_optionControllers.length < 6) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Option'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Poll Guidelines',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Minimum 3 options required'),
                    Text('• Maximum 6 options allowed'),
                    Text('• Be specific and clear'),
                    Text('• Poll will be active for 1 week'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPoll,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Post Poll'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
} 