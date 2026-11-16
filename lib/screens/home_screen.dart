
import 'package:flutter/material.dart';
import 'package:mindshelf_note/theme/color_app.dart';

import '../models/note_model.dart';
import 'category_screen.dart';
import 'favorite_screen.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final TextEditingController _searchController =
      TextEditingController();

  final List<Map<String, dynamic>> _notes = [
    {
      'title': 'Study Notes',
      'description': 'Key concepts for exam...',
      'category': 'Study',
      'date': 'Nov 14',
      'color': const Color(0xFFF6DDE0),
      'icon': Icons.menu_book_rounded,
    },
    {
      'title': 'Daily Journal',
      'description': 'Grateful for today...',
      'category': 'Personal',
      'date': 'Nov 13',
      'color': const Color(0xFFF5E3D9),
      'icon': Icons.edit_note_rounded,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final secondaryColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    final surfaceColor = Theme.of(context).cardTheme.color ??
        Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 15, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _greeting,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _openSettings();
                          },
                          icon: Icon(
                            Icons.settings_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),

                    // TITLE
                    Text(
                      'Your Notes',
                      style: TextStyle(
                        fontSize: 27,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '12 Notes  •  3 Pinned',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 17),

                    // SEARCH BAR
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search your notes...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: secondaryColor,
                          size: 21,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        fillColor: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                        filled: true,
                      ),
                    ),

                    const SizedBox(height: 23),

                    // PINNED NOTES HEADER
                    Row(
                      children: [
                        const Icon(
                          Icons.push_pin_rounded,
                          color: Color(0xFFB34C60),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Pinned Notes',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(40, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'See All ›',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    // PINNED NOTE CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _noteIcon(
                            Icons.description_outlined,
                            const Color(0xFFE8A45F),
                            isDark,
                          ),

                          const SizedBox(width: 11),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Project Plan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Finish UI design and prepare presentation...',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    height: 1.4,
                                    color: secondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _categoryTag('Work', const Color(0xFFF3D7B8)),
                              ],
                            ),
                          ),

                          const SizedBox(width: 5),

                          Column(
                            children: [
                              const Icon(
                                Icons.push_pin_rounded,
                                color: Color(0xFFB34C60),
                                size: 19,
                              ),
                              const SizedBox(height: 35),
                              Text(
                                'Nov 15',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ALL NOTES HEADER
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'All Notes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _showSortOptions,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 4,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Sort',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // NOTE LIST
                    ..._notes
                        .where((note) {
                          final query = _searchController.text.toLowerCase();
                          return note['title']
                                  .toString()
                                  .toLowerCase()
                                  .contains(query) ||
                              note['description']
                                  .toString()
                                  .toLowerCase()
                                  .contains(query);
                        })
                        .map((note) => _noteTile(
                              note: note,
                              textColor: textColor,
                              secondaryColor: secondaryColor,
                              isDark: isDark,
                            )),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ADD NOTE BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 5,
        child: const Icon(
          Icons.add_rounded,
          size: 30,
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.darkDivider
                  : AppColors.lightDivider,
              width: 0.7,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) async {
            if (index == 1) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoriesScreen(),
                ),
              );

              if (!mounted) return;

              setState(() {
                _selectedIndex = 0;
              });

              return;
            }

            if (index == 2) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoritesScreen(),
                ),
              );

              if (!mounted) return;

              setState(() {
                _selectedIndex = 0;
              });

              return;
            }

            setState(() {
              _selectedIndex = index;
            });

            if (index != 0 && index != 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${_navigationLabels[index]} screen will be connected next.',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _navigationLabels = [
    'Home',
    'Categories',
    'Favorites',
    'Settings',
  ];

  Widget _noteIcon(IconData icon, Color color, bool isDark) {
    return Container(
      width: 34,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(
        icon,
        size: 21,
        color: color,
      ),
    );
  }

  Widget _categoryTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _noteTile({
    required Map<String, dynamic> note,
    required Color textColor,
    required Color secondaryColor,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () async {
        final model = note['model'];

        if (model is! NoteModel) return;

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteEditorScreen(note: model),
          ),
        );

        if (!mounted) return;

        if (result == 'deleted') {
          setState(() {
            _notes.removeWhere(
              (item) => item['model']?.id == model.id,
            );
          });
        } else if (result is NoteModel) {
          setState(() {
            final index = _notes.indexWhere(
              (item) => item['model']?.id == result.id,
            );

            if (index != -1) {
              _notes[index] = {
                'title': result.title,
                'description': result.content,
                'category': result.category,
                'date': 'Today',
                'color': Color(result.colorValue),
                'icon': Icons.description_outlined,
                'model': result,
              };
            }
          });
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCard
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? AppColors.darkDivider
                : AppColors.lightDivider.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 36,
              decoration: BoxDecoration(
                color: (note['color'] as Color).withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                note['icon'] as IconData,
                color: const Color(0xFFB77A64),
                size: 19,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note['title'].toString(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    note['description'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _categoryTag(
                    note['category'].toString(),
                    note['color'] as Color,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 7),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.chevron_right_rounded,
                  color: secondaryColor,
                  size: 17,
                ),
                const SizedBox(height: 10),
                Text(
                  note['date'].toString(),
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addNote() async {
    final result = await Navigator.push<NoteModel>(
      context,
      MaterialPageRoute(
        builder: (_) => const NoteEditorScreen(),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _notes.insert(0, {
        'title': result.title,
        'description': result.content,
        'category': result.category,
        'date': 'Today',
        'color': Color(result.colorValue),
        'icon': Icons.description_outlined,
        'model': result,
      });
    });
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings screen will be connected next.'),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Last Edited'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text('Alphabetically'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date Created'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
