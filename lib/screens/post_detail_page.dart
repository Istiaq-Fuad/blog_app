import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blog_app/models/post.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Future<PostModel?> _getPostData() async {
    final doc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .get();
    if (doc.exists) {
      return PostModel.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> toggleLike(PostModel post) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    setState(() {
      if (post.likes.contains(userId)) {
        post.likes.remove(userId);
      } else {
        post.likes.add(userId);
      }
    });

    await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
      'likes': post.likes,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<PostModel?>(
        future: _getPostData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Failed to load post details"));
          }

          final post = snapshot.data!;
          final userId = FirebaseAuth.instance.currentUser!.uid;
          final isLiked = post.likes.contains(userId);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.imageUrl != null)
                  Image.network(
                    post.imageUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post.content,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_alt_outlined,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () => toggleLike(post),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likes.length} upvotes',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.comment, color: Colors.grey, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${post.comments.length} comments',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey),
                      const Text(
                        "Comments",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // for (var comment in post.comments)
                      //   Padding(
                      //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                      //     child: Row(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         CircleAvatar(
                      //           backgroundColor: Colors.blueAccent,
                      //           child: Text(
                      //             comment.userName[0].toUpperCase(),
                      //             style: const TextStyle(color: Colors.white),
                      //           ),
                      //         ),
                      //         const SizedBox(width: 10),
                      //         Expanded(
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               Text(
                      //                 comment.userName,
                      //                 style: const TextStyle(
                      //                   fontSize: 16,
                      //                   fontWeight: FontWeight.bold,
                      //                   color: Colors.blueAccent,
                      //                 ),
                      //               ),
                      //               Text(
                      //                 comment.content,
                      //                 style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
