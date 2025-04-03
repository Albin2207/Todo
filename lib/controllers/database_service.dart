import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_app_firebase/models/todo_model.dart';

class DbService {
  User? get user => FirebaseAuth.instance.currentUser;

  bool get isUserLoggedIn => user != null; // Check if user is logged in

  Future<void> saveUserData(
      {required String name, required String email}) async {
    if (!isUserLoggedIn) {
      print("Error: No authenticated user found.");
      return;
    }

    try {
      Map<String, dynamic> data = {
        "name": name,
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
        "lastUpdated": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection("todo_users")
          .doc(user!.uid)
          .set(data);

      print("User data saved successfully for UID: ${user!.uid}");
    } catch (e) {
      print("Error on saving user data: $e");
      rethrow; // Rethrow to handle in the calling function
    }
  }

  Future<Map<String, dynamic>?> updateUserData(
      {required Map<String, dynamic> extraData}) async {
    if (!isUserLoggedIn) {
      print("Error: No authenticated user found.");
      return null;
    }

    try {
      // Add timestamp for when the data was last updated
      Map<String, dynamic> dataWithTimestamp = {
        ...extraData,
        "lastUpdated": FieldValue.serverTimestamp(),
      };

      print("Updating user data for UID: ${user!.uid}");

      await FirebaseFirestore.instance
          .collection("todo_users") // Changed from shop_users to todo_users
          .doc(user!.uid)
          .set(dataWithTimestamp, SetOptions(merge: true));

      print("User data updated successfully!");

      // Fetch updated data from Firestore to confirm the update
      final updatedDoc = await FirebaseFirestore.instance
          .collection("todo_users") // Changed from shop_users to todo_users
          .doc(user!.uid)
          .get();

      if (updatedDoc.exists) {
        final data = updatedDoc.data();
        print("Updated user data fetched successfully");
        return data;
      } else {
        print("User document not found after update.");
        return null;
      }
    } catch (e) {
      print("Error updating user data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> readUserData() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Error: No authenticated user found.");
      return null;
    }

    String uid = user.uid;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("todo_users") // Changed from shop_users to todo_users
          .doc(uid)
          .get();

      if (doc.exists) {
        print("User data found for UID: $uid");
        return doc.data() as Map<String, dynamic>;
      } else {
        print("No user data exists for UID: $uid");
        return null;
      }
    } catch (e) {
      print("Error reading user data: $e");
      return null;
    }
  }

  // New method to migrate user data from shop_users to todo_users
  Future<void> migrateUserData() async {
    if (!isUserLoggedIn) {
      print("Error: No authenticated user found for migration.");
      return;
    }

    try {
      // Try to get existing data from shop_users
      DocumentSnapshot oldDoc = await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .get();

      if (oldDoc.exists) {
        Map<String, dynamic> oldData = oldDoc.data() as Map<String, dynamic>;
        
        // Transfer only relevant fields to new collection
        Map<String, dynamic> newData = {
          "name": oldData["name"] ?? "",
          "email": oldData["email"] ?? "",
          "username": null,
          "bio": null,
          "migratedAt": FieldValue.serverTimestamp(),
          "createdAt": oldData["createdAt"] ?? FieldValue.serverTimestamp(),
          "lastUpdated": FieldValue.serverTimestamp(),
        };

        // Save to new collection
        await FirebaseFirestore.instance
            .collection("todo_users")
            .doc(user!.uid)
            .set(newData);

        print("User data migrated successfully from shop_users to todo_users for UID: ${user!.uid}");
      }
    } catch (e) {
      print("Error migrating user data: $e");
    }
  }

  // Create new task
Future<String?> createTask({
  required String title,
  required String description,
  required DateTime dueDate,
}) async {
  if (!isUserLoggedIn) {
    print("Error: No authenticated user found.");
    return null;
  }

  try {
    // Create task data
    Map<String, dynamic> taskData = {
      'userId': user!.uid,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Add task to Firestore
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('tasks')
        .add(taskData);

    print("Task created successfully with ID: ${docRef.id}");
    return docRef.id;
  } catch (e) {
    print("Error creating task: $e");
    return null;
  }
}

// Get all tasks for current user
Stream<List<Task>> getTasks() {
  if (!isUserLoggedIn) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('tasks')
      .where('userId', isEqualTo: user!.uid)
      .orderBy('dueDate')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Task.fromDocument(doc)).toList();
      });
}

// Update existing task
Future<bool> updateTask({
  required String taskId,
  String? title,
  String? description,
  DateTime? dueDate,
  bool? isCompleted,
}) async {
  if (!isUserLoggedIn) {
    print("Error: No authenticated user found.");
    return false;
  }

  try {
    Map<String, dynamic> updateData = {};
    
    if (title != null) updateData['title'] = title;
    if (description != null) updateData['description'] = description;
    if (dueDate != null) updateData['dueDate'] = Timestamp.fromDate(dueDate);
    if (isCompleted != null) updateData['isCompleted'] = isCompleted;
    
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(taskId)
        .update(updateData);
        
    print("Task updated successfully: $taskId");
    return true;
  } catch (e) {
    print("Error updating task: $e");
    return false;
  }
}

// Delete task
Future<bool> deleteTask(String taskId) async {
  if (!isUserLoggedIn) {
    print("Error: No authenticated user found.");
    return false;
  }

  try {
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(taskId)
        .delete();
        
    print("Task deleted successfully: $taskId");
    return true;
  } catch (e) {
    print("Error deleting task: $e");
    return false;
  }
}

// Toggle task completion status
Future<bool> toggleTaskCompletion(String taskId, bool currentStatus) async {
  return await updateTask(
    taskId: taskId,
    isCompleted: !currentStatus,
  );
}
}