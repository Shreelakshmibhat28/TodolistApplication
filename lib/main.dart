import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key,Key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/auth', // Set the initial route to the login screen
      routes: {
        '/auth': (context) => LoginScreen(), // Login screen route
        '/todo': (context) => const TodoList(), // To-Do List screen route
      },
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({Key? key});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<String> _todoList = [];
  final TextEditingController _textFieldController = TextEditingController();
  final Set<int> _selectedItems = Set<int>();

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }
//function to load todo
  void _loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _todoList = prefs.getStringList('todo_list') ?? [];
    });
  }
//function to save the added items
  void _saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todo_list', _todoList);
  }
//function to add item
  void _addTodoItem(String item) {
    setState(() {
      _todoList.add(item);
      _saveTodoList();
    });
    _textFieldController.clear();
  }
//function to edit the todolist item
  void _editTodoItem(int index, String newItem) {
    setState(() {
      _todoList[index] = newItem;
      _saveTodoList();
    });
  }
//function to remove the item if no longer needed
  void _removeTodoItem(int index) {
    setState(() {
      _todoList.removeAt(index);
      _saveTodoList();
    });
    // Unselect the item after deletion
    _selectedItems.remove(index);
  }

  //  method to handle logout
  void _logout() {
    Navigator.of(context).pushReplacementNamed('/auth'); // Navigate to the login screen and replace the current route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add your TODO here 😃'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Add a logout button to the appbar
            onPressed: _logout, // Call _logout when the button is pressed
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_selectedItems.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  // Handle selected items, e.g., delete or edit them
                  for (int index in _selectedItems.toList()) {
                    _removeTodoItem(index);
                  }
                  _selectedItems.clear();
                },
                child: const Text('Delete Selected'),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedItems.contains(index);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedItems.remove(index);
                      } else {
                        _selectedItems.add(index);
                      }
                    });
                  },
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: isSelected ? Colors.amberAccent : Colors.white,
                    child: ListTile(
                      title: Text(
                        _todoList[index],
                        style: const TextStyle(fontSize: 18),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              String editedItem = await showDialog(
                                context: context,
                                builder: (context) => _buildEditDialog(_todoList[index]),
                              );
                              _editTodoItem(index, editedItem);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _removeTodoItem(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String newItem = await showDialog(
            context: context,
            builder: (context) => _buildAddDialog(),
          );
          _addTodoItem(newItem);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAddDialog() {
    return AlertDialog(
      title: const Text('Add a new task'),
      content: TextField(controller: _textFieldController),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_textFieldController.text);
          },
          child: const Text('ADD'),
        ),
      ],
    );
  }

  Widget _buildEditDialog(String initialText) {
    TextEditingController editController = TextEditingController(text: initialText);

    return AlertDialog(
      title: const Text('Edit task'),
      content: TextField(controller: editController),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(editController.text);
          },
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
//login method
  void _login() {
    if (_usernameController.text == 'shree' && _passwordController.text == '1234') {
      Navigator.of(context).pushReplacementNamed('/todo'); // Use pushReplacementNamed to replace the login screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check your username and password.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true, // For password field
            ),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
