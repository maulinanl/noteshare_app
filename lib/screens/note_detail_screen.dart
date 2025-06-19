import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import '../services/auth_service.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final AuthService _authService = AuthService();
  final _commentController = TextEditingController();
  bool _isLiked = false;
  int _likes = 0;

  @override
  void initState() {
    super.initState();
    _likes = widget.note.likes;
    _incrementViews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black54),
            onPressed: _shareNote,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorInfo(),
            const SizedBox(height: 24),
            _buildNoteContent(),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 32),
            _buildCommentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.green,
          child: Text(
            widget.note.authorName.isNotEmpty
                ? widget.note.authorName[0].toUpperCase()
                : 'A',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.note.authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatDate(widget.note.createdAt),
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (widget.note.isMonetized)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${widget.note.coinPrice} coins',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNoteContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.note.title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.note.content,
          style: const TextStyle(
            fontSize: 18,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? Colors.red : Colors.black54,
          ),
          onPressed: _toggleLike,
        ),
        Text('$_likes'),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.comment_outlined, color: Colors.black54),
          onPressed: () {
            // Scroll to comments
          },
        ),
        const Text('Comment'),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.black54),
          onPressed: _toggleBookmark,
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildCommentInput(),
        const SizedBox(height: 16),
        _buildCommentsList(),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Write a comment...',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.green),
          onPressed: _addComment,
        ),
      ],
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.note.id)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final comments = snapshot.data!.docs;

        if (comments.isEmpty) {
          return const Text('No comments yet. Be the first to comment!');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index].data() as Map<String, dynamic>;
            return _buildCommentItem(comment);
          },
        );
      },
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.blue,
                child: Text(
                  comment['authorName']?.toString().isNotEmpty == true
                      ? comment['authorName'][0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comment['authorName'] ?? 'Anonymous',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                _formatDate((comment['createdAt'] as Timestamp).toDate()),
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment['content'] ?? ''),
        ],
      ),
    );
  }

  Future<void> _incrementViews() async {
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.note.id)
        .update({'views': FieldValue.increment(1)});
  }

  Future<void> _toggleLike() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() {
      _isLiked = !_isLiked;
      _likes += _isLiked ? 1 : -1;
    });

    await FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.note.id)
        .update({'likes': FieldValue.increment(_isLiked ? 1 : -1)});
  }

  Future<void> _toggleBookmark() async {
    // TODO: Implement bookmark functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bookmark feature coming soon!')),
    );
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = _authService.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.note.id)
        .collection('comments')
        .add({
      'content': _commentController.text.trim(),
      'authorId': user.uid,
      'authorName': user.displayName ?? 'Anonymous',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
  }

  void _shareNote() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Report'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement report functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Block Author'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement block functionality
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
