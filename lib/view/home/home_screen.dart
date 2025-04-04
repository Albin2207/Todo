import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app_firebase/controllers/database_service.dart';
import 'package:todo_app_firebase/models/todo_model.dart';
import 'package:todo_app_firebase/view/todo%20screens/add_todo.dart';
import 'package:todo_app_firebase/view/todo%20screens/edit_todo.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late DbService _dbService;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _dbService = DbService();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
          indicatorColor: Color(0xFF1E6F9F),
          labelColor: Colors.white,
        ),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view your tasks'))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(null), // All tasks
                _buildTaskList(false), // Pending tasks only
                _buildTaskList(true), // Completed tasks only
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          );
        },
      ),
    );
  }

  Widget _buildTaskList(bool? completionFilter) {
    return StreamBuilder<List<Task>>(
      stream: _dbService.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Apply filter based on tab
        List<Task> allTasks = snapshot.data ?? [];
        final tasks = completionFilter == null
            ? allTasks
            : allTasks.where((task) => task.isCompleted == completionFilter).toList();

        if (tasks.isEmpty) {
          String message = completionFilter == null
              ? 'No tasks yet! Add a new task to get started.'
              : completionFilter
                  ? 'No completed tasks yet.'
                  : 'No pending tasks. All caught up!';
          
          return Center(
            child: Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final isOverdue = task.dueDate.isBefore(DateTime.now()) && 
                            !task.isCompleted;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 4,
              ),
              child: ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    if (value != null) {
                      _dbService.toggleTaskCompletion(
                        task.id,
                        task.isCompleted,
                      );
                    }
                  },
                  activeColor: Color(0xFF1E6F9F),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(task.description),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Due: ${_dateFormat.format(task.dueDate)}',
                        style: TextStyle(
                          color: isOverdue ? Colors.red : null,
                          fontWeight: isOverdue ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                    if (!task.isCompleted && isOverdue)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Overdue!',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTaskPage(task: task),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteConfirmationDialog(task);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTaskPage(task: task),
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

  Future<void> _showDeleteConfirmationDialog(Task task) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete "${task.title}"?'),
                const Text(
                  'This action cannot be undone.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                _dbService.deleteTask(task.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}