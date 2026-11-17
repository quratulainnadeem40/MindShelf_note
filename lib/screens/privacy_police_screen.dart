
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const String supportEmail =
      'innovexa.technologies01@gmail.com';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black87);
    final secondaryColor = isDark
        ? Colors.white70
        : Colors.black54;
    final borderColor = isDark
        ? Colors.white12
        : Colors.black12;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: textColor,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.privacy_tip_rounded,
                      color: gold,
                      size: 32,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: gold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'For Shelf Note',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Last updated: November 16, 2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _paragraph(
                'Innovexa Technologies ("we", "our", or "us") respects your privacy. '
                'This Privacy Policy explains how information may be handled when you use '
                'the Shelf Note mobile application ("App").',
                textColor,
              ),

              _section(
                '1. Information You Add to the App',
                [
                  'Shelf Note lets you create and manage notes, including note titles, '
                  'written content, categories, preferences, and any images you choose '
                  'to add. This information is used to provide the App\'s note-taking features.',
                  'Storage: The current app implementation is designed to save notes and '
                  'app preferences on your device using local storage. Information saved '
                  'only on your device is not automatically available to us. If a future '
                  'version adds account, cloud-sync, backup, analytics, or other online '
                  'services, this section must be updated to explain those services and '
                  'their data handling.',
                ],
                textColor,
                secondaryColor,
              ),

              _section(
                '2. How We Use Information',
                [
                  'Information you enter is used to operate the App\'s features, such as:',
                ],
                textColor,
                secondaryColor,
              ),

              _bulletList([
                'Creating, editing, organizing, and deleting notes.',
                'Managing categories, favorites, pinned notes, and Trash.',
                'Remembering app preferences and settings.',
                'Responding to support requests that you send to us.',
              ], secondaryColor),

              _section(
                '3. Sharing and Disclosure',
                [
                  'We do not sell your personal information. We do not access or share '
                  'note content stored locally on your device unless you choose to share '
                  'it through a feature or service on your device.',
                  'If the App is configured with advertising, analytics, crash-reporting, '
                  'cloud storage, or other third-party SDKs, those providers may process '
                  'certain information under their own privacy policies. The developer '
                  'should list those providers here before publishing this policy if they '
                  'are included in the released app.',
                ],
                textColor,
                secondaryColor,
              ),

              _section(
                '4. Permissions',
                [
                  'The App may request access to device features, such as photos or media, '
                  'when you choose to add an image to a note. Permission access is used '
                  'for the feature you request. You can review or change app permissions '
                  'in your device settings.',
                ],
                textColor,
                secondaryColor,
              ),

              _section(
                '5. Data Security and Retention',
                [
                  'Notes stored locally remain on your device until you delete them or '
                  'remove the App and its data. Items moved to Trash may remain in the '
                  'App until you restore them or permanently delete them. You are '
                  'responsible for keeping your device secure and maintaining any '
                  'backups you need.',
                  'No method of electronic storage is completely secure. We therefore '
                  'cannot guarantee absolute security of information stored on your device.',
                ],
                textColor,
                secondaryColor,
              ),

              _section(
                '6. Children\'s Privacy',
                [
                  'The App is not designed to knowingly collect personal information '
                  'from children. If you believe a child has provided personal information '
                  'to us directly, please contact us so we can review the request.',
                ],
                textColor,
                secondaryColor,
              ),

              _section(
                '7. Your Choices',
                [
                  'You can edit or delete notes within the App. You can also manage '
                  'permissions through your device settings. Uninstalling the App may '
                  'remove locally stored app data, depending on your device and backup settings.',
                ],
                textColor,
                secondaryColor,
              ),

              _section(
                '8. Changes to This Privacy Policy',
                [
                  'We may update this Privacy Policy when the App or its practices change. '
                  'Any update will be posted on this page with a revised "Last updated" date. '
                  'Please review this page periodically.',
                ],
                textColor,
                secondaryColor,
              ),

              _section(
                '9. Contact Us',
                [
                  'If you have any questions, suggestions, or concerns regarding this '
                  'Privacy Policy, please contact:',
                ],
                textColor,
                secondaryColor,
              ),

              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: gold.withValues(alpha: 0.45)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Innovexa Technologies',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: gold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Support Email',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            supportEmail,
                            style: TextStyle(
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Copy email',
                          onPressed: () {
                            Clipboard.setData(
                              const ClipboardData(text: supportEmail),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email copied'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.copy_rounded,
                            color: gold,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Divider(color: borderColor),

              const SizedBox(height: 15),

              Center(
                child: Text(
                  '© 2026 Innovexa Technologies. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(
    String title,
    List<String> paragraphs,
    Color textColor,
    Color secondaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: gold,
            ),
          ),
          const SizedBox(height: 9),
          ...paragraphs.map(
            (paragraph) => _paragraph(paragraph, secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _paragraph(String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 13,
          height: 1.7,
          color: color,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _bulletList(List<String> items, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: gold,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
