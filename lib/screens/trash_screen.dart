
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/local_storage_service.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final NoteServices _noteService = NoteServices();

  List<NoteModel> _deletedNotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrash();
  }

  Future<void> _loadTrash() async {
    setState(() => _isLoading = true);

    final notes = await _noteService.getDeletedNotes();

    if (!mounted) return;

    setState(() {
      _deletedNotes = notes;
      _isLoading = false;
    });
  }

  Future<void> _restoreNote(NoteModel note) async {
    await _noteService.restoreNote(note.id);
    await _loadTrash();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note restored successfully'),
      ),
    );
  }

  Future<void> _deletePermanently(NoteModel note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently?'),
        content: const Text(
          'This note will be permanently deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _noteService.permanentlyDeleteNote(note.id);
    await _loadTrash();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note permanently deleted'),
      ),
    );
  }

  Future<void> _emptyTrash() async {
    if (_deletedNotes.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash?'),
        content: const Text(
          'Are you sure you want to permanently delete all notes in Trash?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Empty Trash',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _noteService.emptyTrash();
    await _loadTrash();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trash emptied successfully'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    return '${localDate.day}/${localDate.month}/${localDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Trash',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          if (_deletedNotes.isNotEmpty)
            IconButton(
              tooltip: 'Empty Trash',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _emptyTrash,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deletedNotes.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _loadTrash,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          '${_deletedNotes.length} deleted note(s)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                      ..._deletedNotes.map(
                        (note) => _buildNoteCard(note, theme),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Notes in Trash can be restored or permanently deleted.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              size: 75,
              color: theme.hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Trash is Empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Deleted notes will appear here.',
              style: TextStyle(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title.isEmpty ? 'Untitled Note' : note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              note.content.isEmpty ? 'No content' : note.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 15,
                  color: theme.hintColor,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    note.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.hintColor,
                    ),
                  ),
                ),
                Text(
                  _formatDate(note.updatedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _restoreNote(note),
                  icon: const Icon(Icons.restore, size: 18),
                  label: const Text('Restore'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deletePermanently(note),
                  icon: const Icon(
                    Icons.delete_forever_outlined,
                    size: 18,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
