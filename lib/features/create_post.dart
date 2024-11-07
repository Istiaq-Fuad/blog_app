import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> createPost(String title, String content, String? imageUrl) async {
  FirebaseFirestore.instance.collection('posts').add({
    'title': title,
    'content': content,
    'authorId': FirebaseAuth.instance.currentUser!.uid,
    'imageUrl': imageUrl, // Store the image URL
    'likes': [],
    'comments': [],
    'createdAt': Timestamp.now(),
  });
}
