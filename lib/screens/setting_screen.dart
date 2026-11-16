
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/theme_provider.dart';
import '../theme/color_app.dart';
import 'category_screen.dart';
import 'favorite_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _defaultCategory = 'Personal';
  String _sortOrder = 'Last Edited';
  String _layout = 'List';
  int _noteColor = 0;

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

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _defaultCategory =
          prefs.getString('default_category') ?? 'Personal';
      _sortOrder =
          prefs.getString('notes_sort_order') ?? 'Last Edited';
      _layout = prefs.getString('notes_layout') ?? 'List';
      _noteColor = prefs.getInt('default_note_color') ?? 0;
    });
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _saveColor(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('default_note_color', index);

    if (!mounted) return;
    setState(() => _noteColor = index);
  }

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
                      'SimplyNote • Your thoughts, beautifully organized.',
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          border: Border(
            top: BorderSide(
              color: _borderColor,
              width: 0.7,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: 3,
          type: BottomNavigationBarType.fixed,
          backgroundColor: _cardColor,
          selectedItemColor: _accentColor,
          unselectedItemColor: _secondaryColor,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
          ),
          onTap: (index) async {
            if (index == 0) {
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              );
              return;
            }

            if (index == 1) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoriesScreen(),
                ),
              );
              return;
            }

            if (index == 2) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoritesScreen(),
                ),
              );
              return;
            }

            if (index == 3) {
              return;
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
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.maybePop(context);
              },
              icon: Icon(
                Icons.arrow_back_rounded,
                color: _textColor,
                size: 23,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 35,
                minHeight: 40,
              ),
            ),
            const SizedBox(width: 8),
            Text(
                'Settings',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                  color: _textColor,
                ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 43),
          child: Text(
            'Personalize your SimplyNote experience.',
            style: TextStyle(
              fontSize: 12,
              color: _secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

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
            'Choose how SimplyNote looks',
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
                _colorDot(_noteColors[_noteColor.clamp(
                  0,
                  _noteColors.length - 1,
                )]),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded,
                    color: _secondaryColor),
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
          _settingTile(
            icon: Icons.sort_rounded,
            title: 'Sorting Preferences',
            subtitle: _sortOrder,
            onTap: _showSortPicker,
          ),
          _divider(),
          _settingTile(
            icon: Icons.view_agenda_outlined,
            title: 'Note Display Layout',
            subtitle: _layout,
            onTap: _showLayoutPicker,
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _settingTile(
            icon: Icons.folder_copy_outlined,
            title: 'Manage Categories',
            subtitle: 'Organize your note categories',
            onTap: () => _showInformation(
              'Manage Categories',
              'Category management will be connected to your Categories screen.',
            ),
          ),
          _divider(),
          _settingTile(
            icon: Icons.delete_outline_rounded,
            title: 'Trash',
            subtitle: 'View deleted notes',
            onTap: () => _showInformation(
              'Trash',
              'Your deleted notes will appear here once trash functionality is connected.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _settingTile(
            icon: Icons.info_outline_rounded,
            title: 'About SimplyNote',
            subtitle: 'Version 1.0.0',
            onTap: () => _showInformation(
              'About SimplyNote',
              'SimplyNote is your personal space for capturing ideas, organizing thoughts and keeping important notes together.',
            ),
          ),
          _divider(),
          _settingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Information',
            subtitle: 'Your privacy matters',
            onTap: () => _showInformation(
              'Privacy Information',
              'Add your application privacy policy here before publishing.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardHeading(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Icon(icon, color: _accentColor, size: 21),
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
      leading: Icon(icon, color: _accentColor, size: 21),
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

  Widget _colorDot(Color color) {
    return Container(
      width: 23,
      height: 23,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: _borderColor),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: _borderColor, width: 0.7),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.6,
      color: _borderColor,
    );
  }

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
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
      },
    );
  }

  Future<void> _showCategoryPicker() async {
    const categories = [
      'Personal',
      'Work',
      'Study',
      'Ideas',
      'General',
    ];

    final result = await _showChoiceSheet(
      'Default Category',
      categories,
      _defaultCategory,
    );

    if (result != null) {
      setState(() => _defaultCategory = result);
      await _saveString('default_category', result);
    }
  }

  Future<void> _showSortPicker() async {
    const options = [
      'Last Edited',
      'Date Created',
      'Alphabetically',
    ];

    final result = await _showChoiceSheet(
      'Sort Notes',
      options,
      _sortOrder,
    );

    if (result != null) {
      setState(() => _sortOrder = result);
      await _saveString('notes_sort_order', result);
    }
  }

  Future<void> _showLayoutPicker() async {
    const options = ['List', 'Grid'];

    final result = await _showChoiceSheet(
      'Note Display Layout',
      options,
      _layout,
    );

    if (result != null) {
      setState(() => _layout = result);
      await _saveString('notes_layout', result);
    }
  }

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
                      style: TextStyle(color: _textColor),
                    ),
                    trailing: selected == option
                        ? Icon(Icons.check_circle,
                            color: _accentColor)
                        : null,
                    onTap: () => Navigator.pop(context, option),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInformation(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text(
          title,
          style: TextStyle(color: _textColor),
        ),
        content: Text(
          message,
          style: TextStyle(color: _secondaryColor),
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
