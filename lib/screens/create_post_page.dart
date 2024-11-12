import 'package:blog_app/features/create_post.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titleController = TextEditingController();
  final quill.QuillController _contentController =
      quill.QuillController.basic();
  File? _image;

  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  // Don't forget to dispose of them
  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        _image = File(imageFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    final storageRef = FirebaseStorage.instance.ref();
    final imageRef =
        storageRef.child('posts/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await imageRef.putFile(_image!);
    return await imageRef.getDownloadURL();
  }

  Future<void> _createPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.document.toDelta().toJson();

    if (title.isEmpty || content.isEmpty) return;

    String? imageUrl = await _uploadImage();
    await createPost(title, content, imageUrl);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a Post"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  image: _image != null
                      ? DecorationImage(
                          image: FileImage(_image!), fit: BoxFit.cover)
                      : null,
                ),
                child: _image == null
                    ? Center(
                        child: Text("Tap to select an image",
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 16)))
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            // Title Input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Rich Text Editor (Quill)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  quill.QuillToolbar.simple(controller: _contentController),
                  const Divider(height: 1, color: Colors.grey),
                  Container(
                    height: 200, // Adjust based on preference
                    padding: const EdgeInsets.all(8.0),
                    child: quill.QuillEditor(
                      controller: _contentController,
                      scrollController: _scrollController,
                      focusNode: _focusNode,
                      configurations: const quill.QuillEditorConfigurations(
                          scrollable: true,
                          showCursor: true,
                          autoFocus: true,
                          expands: false,
                          padding: EdgeInsets.zero),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Post Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createPost,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Post",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
