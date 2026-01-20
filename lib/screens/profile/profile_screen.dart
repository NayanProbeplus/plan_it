import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planit/core/router.dart';
import 'package:planit/models/profile_model.dart';
import 'package:planit/providers/profile_provider.dart';
import 'package:planit/widgets/glass_edittexts_textfields.dart';
import 'package:planit/widgets/slide_to_confirm_button.dart';
import 'package:planit/theme/colors.dart';
import 'package:planit/widgets/staggered_fade_animation.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers (stable – do not reset)
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;

  String _gender = 'Prefer not to say';
  String? _imagePath;

  late final AnimationController _animCtrl;
  late final Animation<double> _scale;

  final _genderOptions = ['Male', 'Female', 'Prefer not to say'];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final profile = ref.read(profileNotifierProvider).valueOrNull;

    _nameCtrl = TextEditingController(text: profile?.name ?? '');
    _emailCtrl = TextEditingController(text: profile?.email ?? '');
    _gender = profile?.gender ?? _gender;
    _imagePath = profile?.imagePath;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.98, end: 1.03).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ---------------- SAVE ----------------

  Future<bool> _onSave(Profile currentProfile) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix validation errors')),
      );
      return false;
    }

    final updated = Profile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      gender: _gender,
      imagePath: _imagePath,
    );

    try {
      await ref.read(profileNotifierProvider.notifier).save(updated);
      Fluttertoast.showToast(msg: 'Profile saved successfully');
      if (mounted) context.push(Routes.home);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $e')));
      return false;
    }
  }

  // ---------------- IMAGE PICKING ----------------

  void _showImageOptions() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_album_rounded),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_sweep_rounded,
                    color: AppColors.errorRed),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
            const ListTile(
              leading: Icon(Icons.close_rounded),
              title: Text('Cancel'),
            ),
          ]),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;

    await ref
        .read(profileNotifierProvider.notifier)
        .updateImagePath(picked.path);

    if (mounted) setState(() => _imagePath = picked.path);
  }

  Future<void> _removeImage() async {
    await ref.read(profileNotifierProvider.notifier).updateImagePath(null);
    if (mounted) setState(() => _imagePath = null);
  }

  // ---------------- VALIDATION ----------------

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter an email';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(v.trim()) ? null : 'Enter a valid email';
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final avatarSize = MediaQuery.of(context).size.width * 0.36;

    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.outline),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: StaggeredFade(
                    children: [
                      const SizedBox(height: 8),

                      // -------- AVATAR --------
                      Center(
                        child: GestureDetector(
                          onTap: _showImageOptions,
                          child: ScaleTransition(
                            scale: _scale,
                            child: Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: theme.brightness == Brightness.dark
                                    ? AppColors.darkAccentGradient
                                    : AppColors.vibrantGradientBg,
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.primary.withOpacity(0.12),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: ClipOval(
                                child: Container(
                                  color: cs.surface,
                                  child: _imagePath != null &&
                                          File(_imagePath!).existsSync()
                                      ? Image.file(File(_imagePath!),
                                          fit: BoxFit.cover)
                                      : Image.asset(
                                          'assets/images/profile.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // -------- FORM --------
                      Form(
                        key: _formKey,
                        child: Column(children: [
                          GlassInputWrapper(
                            child: RoundedTextFieldContent(
                              controller: _nameCtrl,
                              labelText: 'Name',
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Enter a name'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GlassInputWrapper(
                            child: RoundedTextFieldContent(
                              controller: _emailCtrl,
                              labelText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: _emailValidator,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GlassInputWrapper(
                            child: RoundedDropdownContent<String>(
                              value: _gender,
                              labelText: 'Gender',
                              items: _genderOptions,
                              onChanged: (v) =>
                                  setState(() => _gender = v ?? _gender),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),

              // -------- SAVE --------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: SlideToConfirmButton(
                  visible: true,
                  title: 'Slide to save',
                  showIcon: true,
                  width: MediaQuery.of(context).size.width - 40,
                  onConfirmed: () => _onSave(profile),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
