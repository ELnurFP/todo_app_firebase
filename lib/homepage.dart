import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable, use_key_in_widget_constructors
class HomePage extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('todos')
                          .snapshots(),
                      builder: (context, snapshot) {
                        final todos = snapshot.data?.docs;
                        if (todos == null) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (todos.isEmpty) {
                          return const Center(child: Text('No todos yet!'));
                        }
                        return ListView.builder(
                          itemCount: todos.length,
                          itemBuilder: (context, index) {
                            final todo = todos[index];
                            return Card(
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                title: Text(todo['todo']),
                                subtitle: Text(
                                  DateFormat('HH:mm       dd-MM-yyyy').format(
                                    todo['createdAt'].toDate(),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('todos')
                                        .doc(todos[index].id)
                                        .delete();
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      })),
              _inputField(),
            ],
          ),
        ),
      ),
    );
  }

  Padding _inputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Add Todo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('todos').add(
                  {'todo': _textController.text, 'createdAt': Timestamp.now()});
              _textController.clear();
            },
            icon: const Icon(
              Icons.send_rounded,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
