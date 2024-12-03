import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiscussionPage extends StatefulWidget {
  const DiscussionPage({super.key});

  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _postController = TextEditingController();
  String _topic = '오늘의 대화 주제: 서로 인사를 나눠보세요';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _topic,
          style: const TextStyle(color: Color(0xFFE9F2EE)),
        ),
        backgroundColor: const Color(0xFF4B443F),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('posts')
            .orderBy('likes', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('아직 작성된 글이 없습니다.'));
          }
          final posts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(post['content']),
                  subtitle: Text('작성자: ${post['author']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${post['likes']}'),
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: post['likes'] > 0 ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _incrementLike(post.id, post['likes']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4B443F),
        onPressed: () => _showPostDialog(context),
        child: const Icon(Icons.add, color: Color(0xFFE9F2EE)),
      ),
    );
  }

  void _showPostDialog(BuildContext context) {
    _postController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 글 작성'),
        content: TextField(
          controller: _postController,
          decoration: const InputDecoration(hintText: '글 내용을 입력하세요'),
          maxLength: 200,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B443F),
            ),
            onPressed: () {
              if (_postController.text.trim().isNotEmpty) {
                _addNewPost(_postController.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('등록'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewPost(String content) async {
    try {
      await _firestore.collection('posts').add({
        'author': '익명', // 회원 정보에서 작성자를 가져오도록 수정 가능
        'content': content,
        'likes': 0,
        'timestamp': FieldValue.serverTimestamp(), // 작성 시간
      });
    } catch (e) {
      print('Error adding post: $e');
    }
  }

  Future<void> _incrementLike(String postId, int currentLikes) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': currentLikes + 1,
      });
    } catch (e) {
      print('Error updating likes: $e');
    }
  }
}
