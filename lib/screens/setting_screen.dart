
import 'package:flutter/material.dart';
import 'package:mindshelf_note/screens/privacy_police_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindshelf_note/services/note_service.dart';

import '../providers/theme_provider.dart';
import '../theme/color_app.dart';

import 'category_screen.dart';
import 'favorite_screen.dart';
import 'trash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NoteServices _noteService = NoteServices();

  static const Color _gold = Color(0xFFE2B85F);

  String _defaultCategory = 'Personal';
  String _sortOrder = 'Date Created';
  String _layout = 'List';

  int _noteColor = 0;

  List<String> _categories = ['Personal'];

  bool _isLoadingCategories = false;

  static const List<String> _sortOptions = [
    'Date Created',
    'Alphabetically',
  ];

  static const List<Color> _noteColors = [
    AppColors.notePink,
    AppColors.noteYellow,
    AppColors.notePurple,
    AppColors.noteGreen,
    AppColors.noteBlue,
    AppColors.notePeach,
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // LOAD PREFERENCES AND DYNAMIC CATEGORIES

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categories = await _noteService.getCategories();

      if (!mounted) return;

      String defaultCategory =
          prefs.getString('default_category') ?? 'Personal';

      if (!categories.contains(defaultCategory)) {
        defaultCategory = 'Personal';
      }

      // Last Edited is no longer supported.
      String savedSortOrder =
          prefs.getString('notes_sort_order') ?? 'Date Created';

      if (!_sortOptions.contains(savedSortOrder)) {
        savedSortOrder = 'Date Created';

        await prefs.setString(
          'notes_sort_order',
          savedSortOrder,
        );
      }

      setState(() {
        _categories = categories;
        _defaultCategory = defaultCategory;
        _sortOrder = savedSortOrder;

        _layout = prefs.getString('notes_layout') ?? 'List';

        _noteColor = prefs.getInt('default_note_color') ?? 0;
      });

      await prefs.setString(
        'default_category',
        defaultCategory,
      );
    } catch (e) {
      debugPrint('Settings loading error: $e');
    }
  }

  // SAVE STRING PREFERENCE

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // SAVE DEFAULT COLOR

  Future<void> _saveColor(int index) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('default_note_color', index);

    if (!mounted) return;

    setState(() {
      _noteColor = index;
    });
  }

  // THEME COLORS

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _textColor =>
      _isDark ? AppColors.darkText : AppColors.lightText;

  Color get _secondaryColor =>
      _isDark
          ? AppColors.darkSecondaryText
          : AppColors.lightSecondaryText;

  Color get _cardColor =>
      _isDark ? AppColors.darkCard : AppColors.lightSurface;

  Color get _borderColor =>
      _isDark ? AppColors.darkDivider : AppColors.lightDivider;

  Color get _accentColor =>
      _isDark ? AppColors.darkPrimary : AppColors.primary;

  // MAIN UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),

                  const SizedBox(height: 27),

                  _sectionTitle('APPEARANCE'),
                  const SizedBox(height: 12),
                  _buildAppearanceCard(),

                  const SizedBox(height: 25),

                  _sectionTitle('PREFERENCES'),
                  const SizedBox(height: 12),
                  _buildPreferencesCard(),

                  const SizedBox(height: 25),

                  _sectionTitle('ORGANIZATION'),
                  const SizedBox(height: 12),
                  _buildOrganizationCard(),

                  const SizedBox(height: 25),

                  _sectionTitle('APPLICATION'),
                  const SizedBox(height: 12),
                  _buildApplicationCard(),

                  const SizedBox(height: 28),

                  Center(
                    child: Text(
                      'Shelf Note • A beautiful space for your thoughts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: _secondaryColor,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // BOTTOM NAVIGATION

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        height: 65,
        margin: const EdgeInsets.fromLTRB(18, 5, 18, 10),
        decoration: BoxDecoration(
          color: _isDark
              ? const Color(0xFF242424)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isDark
                ? const Color(0xFF383838).withValues(alpha: 0.4)
                : const Color(0xFFE8E0D2).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            _settingsNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
            ),
            _settingsNavItem(
              icon: Icons.grid_view_rounded,
              label: 'Categories',
              index: 1,
            ),
            _settingsNavItem(
              icon: Icons.favorite_rounded,
              label: 'Favorites',
              index: 2,
            ),
            _settingsNavItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  // NAV ITEM

  Widget _settingsNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = index == 3;

    final unselectedColor = _isDark
        ? Colors.white54
        : Colors.grey.shade600;

    return Expanded(
      child: InkWell(
        onTap: () async {
          if (index == 0) {
            Navigator.popUntil(
              context,
              (route) => route.isFirst,
            );
          } else if (index == 1) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoriesScreen(),
              ),
            );
          } else if (index == 2) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FavoritesScreen(),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? _gold : unselectedColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w500,
                  color: selected ? _gold : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _isDark
                    ? AppColors.darkCard
                    : AppColors.lightSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _gold.withValues(alpha: 0.55),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.maybePop(context);
                },
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: _gold,
                  size: 23,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Settings & Preferences',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                  color: _textColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Padding(
          padding: const EdgeInsets.only(left: 54),
          child: Text(
            'Manage your app experience and preferences.',
            style: TextStyle(
              fontSize: 12,
              color: _secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // SECTION TITLE

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: _accentColor,
      ),
    );
  }

  // APPEARANCE CARD

  Widget _buildAppearanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeading(
            Icons.palette_outlined,
            'Theme Appearance',
            'Choose how Shelf Note looks',
          ),
          const SizedBox(height: 17),
          Consumer<ThemeProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  _themeOption(
                    ThemeMode.light,
                    Icons.light_mode_rounded,
                    'Light',
                    provider,
                  ),
                  const SizedBox(width: 9),
                  _themeOption(
                    ThemeMode.dark,
                    Icons.dark_mode_rounded,
                    'Dark',
                    provider,
                  ),
                  const SizedBox(width: 9),
                  _themeOption(
                    ThemeMode.system,
                    Icons.settings_suggest_rounded,
                    'System',
                    provider,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // THEME OPTION

  Widget _themeOption(
    ThemeMode mode,
    IconData icon,
    String label,
    ThemeProvider provider,
  ) {
    final selected = provider.themeMode == mode;

    return Expanded(
      child: InkWell(
        onTap: () => provider.setTheme(mode),
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: selected
                ? _accentColor.withValues(alpha: 0.12)
                : (_isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? _accentColor : _borderColor,
              width: selected ? 1.5 : 0.8,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? _accentColor : _secondaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? _accentColor : _textColor,
                ),
              ),
              const SizedBox(height: 5),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: _accentColor,
                  size: 14,
                )
              else
                const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  // PREFERENCES CARD

  Widget _buildPreferencesCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _settingTile(
            icon: Icons.color_lens_outlined,
            title: 'Default Note Color',
            subtitle: 'Choose your preferred note color',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _colorDot(
                  _noteColors[_noteColor.clamp(
                    0,
                    _noteColors.length - 1,
                  )],
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _secondaryColor,
                ),
              ],
            ),
            onTap: _showColorPicker,
          ),

          _divider(),

          _settingTile(
            icon: Icons.folder_outlined,
            title: 'Default Category',
            subtitle: _defaultCategory,
            onTap: _showCategoryPicker,
          ),

          _divider(),

          // UPDATED SORTING ICON

          _settingTile(
            icon: Icons.swap_vert_rounded,
            title: 'Sorting Preferences',
            subtitle: _sortOrder,
            onTap: _showSortPicker,
          ),

          _divider(),

          _settingTile(
            icon: _layout == 'Grid'
                ? Icons.grid_view_rounded
                : Icons.view_agenda_outlined,
            title: 'Note Display Layout',
            subtitle: 'Currently selected: $_layout View',
            onTap: _showLayoutPicker,
          ),
        ],
      ),
    );
  }

  // ORGANIZATION CARD

  Widget _buildOrganizationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _settingTile(
            icon: Icons.folder_copy_outlined,
            title: 'Manage Categories',
            subtitle: 'Add, rename and organize categories',
            onTap: _openManageCategories,
            trailing: _isLoadingCategories
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    Icons.chevron_right_rounded,
                    color: _secondaryColor,
                  ),
          ),
          _divider(),
          _settingTile(
            icon: Icons.delete_outline_rounded,
            title: 'Trash',
            subtitle: 'View deleted notes',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TrashScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // OPEN CATEGORY SCREEN AND REFRESH

  Future<void> _openManageCategories() async {
    if (_isLoadingCategories) return;

    setState(() {
      _isLoadingCategories = true;
    });

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CategoriesScreen(),
        ),
      );

      if (!mounted) return;

      final categories = await _noteService.getCategories();
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      String updatedDefault = _defaultCategory;

      if (!categories.contains(updatedDefault)) {
        updatedDefault = 'Personal';
      }

      setState(() {
        _categories = categories;
        _defaultCategory = updatedDefault;
      });

      await prefs.setString(
        'default_category',
        updatedDefault,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to refresh categories: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  // APPLICATION CARD

  Widget _buildApplicationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _settingTile(
            icon: Icons.info_outline_rounded,
            title: 'About Shelf Note',
            subtitle: 'Version 1.0.0',
            onTap: () => _showInformation(
              'About Shelf Note',
              'Shelf Note is your personal space for capturing ideas, '
                  'organizing thoughts and keeping important notes together.',
            ),
          ),
          _divider(),
          _settingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read how Shelf Note handles your data',
            onTap: _openPrivacyPolicy,
          ),
        ],
      ),
    );
  }

  // OPEN PRIVACY POLICY

  void _openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  }

  // CARD HEADING

  Widget _cardHeading(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: _accentColor,
          size: 21,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: _secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // SETTING TILE

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 3),
      minLeadingWidth: 30,
      horizontalTitleGap: 12,
      leading: Icon(
        icon,
        color: _accentColor,
        size: 21,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _textColor,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: _secondaryColor,
          ),
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: _secondaryColor,
          ),
      onTap: onTap,
    );
  }

  // COLOR DOT

  Widget _colorDot(Color color) {
    return Container(
      width: 23,
      height: 23,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: _borderColor,
        ),
      ),
    );
  }

  // CARD DECORATION

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(
        color: _borderColor,
        width: 0.7,
      ),
    );
  }

  // UPDATED VISIBLE GOLD DIVIDER

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: _isDark
          ? Colors.white.withValues(alpha: 0.13)
          : const Color(0xFFE8D8B9),
      indent: 0,
      endIndent: 0,
    );
  }

  // COLOR PICKER

  Future<void> _showColorPicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Default Note Color',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: List.generate(
                    _noteColors.length,
                    (index) {
                      return InkWell(
                        onTap: () async {
                          await _saveColor(index);

                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                        child: Container(
                          width: 43,
                          height: 43,
                          decoration: BoxDecoration(
                            color: _noteColors[index],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _noteColor == index
                                  ? _accentColor
                                  : _borderColor,
                              width: _noteColor == index ? 3 : 1,
                            ),
                          ),
                          child: _noteColor == index
                              ? const Icon(
                                  Icons.check,
                                  color: Color(0xFF501E2C),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  // DYNAMIC CATEGORY PICKER

  Future<void> _showCategoryPicker() async {
    final categories = await _noteService.getCategories();

    if (!mounted) return;

    setState(() {
      _categories = categories;

      if (!_categories.contains(_defaultCategory)) {
        _defaultCategory = 'Personal';
      }
    });

    final result = await _showChoiceSheet(
      'Default Category',
      _categories,
      _defaultCategory,
    );

    if (result != null && mounted) {
      setState(() {
        _defaultCategory = result;
      });

      await _saveString(
        'default_category',
        result,
      );
    }
  }

  // SORT PICKER — LAST EDITED REMOVED

  Future<void> _showSortPicker() async {
    final result = await _showChoiceSheet(
      'Sorting Preferences',
      _sortOptions,
      _sortOrder,
    );

    if (result != null && mounted) {
      setState(() {
        _sortOrder = result;
      });

      await _saveString(
        'notes_sort_order',
        result,
      );
    }
  }

  // LAYOUT PICKER

  Future<void> _showLayoutPicker() async {
    const options = [
      'List',
      'Grid',
    ];

    final result = await _showChoiceSheet(
      'Note Display Layout',
      options,
      _layout,
    );

    if (result != null && mounted) {
      await _saveString(
        'notes_layout',
        result,
      );

      if (!mounted) return;

      setState(() {
        _layout = result;
      });
    }
  }

  // CHOICE BOTTOM SHEET

  Future<String?> _showChoiceSheet(
    String title,
    List<String> options,
    String selected,
  ) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map(
                  (option) => ListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        color: _textColor,
                      ),
                    ),
                    trailing: selected == option
                        ? Icon(
                            Icons.check_circle,
                            color: _accentColor,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context, option);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // INFORMATION DIALOG

  void _showInformation(
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text(
          title,
          style: TextStyle(
            color: _textColor,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: _secondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
