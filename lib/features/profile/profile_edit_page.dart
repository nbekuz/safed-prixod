import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/core/app_providers.dart';
import 'package:safed_prixod/core/locale_provider.dart';
import 'package:safed_prixod/features/profile/profile_page.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({
    super.key,
    required this.initialFirstName,
    required this.initialLastName,
  });

  final String initialFirstName;
  final String initialLastName;

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.initialFirstName);
    _lastNameCtrl = TextEditingController(text: widget.initialLastName);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = ref.read(l10nProvider);
    if (!_formKey.currentState!.validate()) return;

    final first = _firstNameCtrl.text.trim();
    final last = _lastNameCtrl.text.trim();

    setState(() => _saving = true);
    try {
      await ref.read(authApiProvider).updateProfile(
        firstName: first,
        lastName: last,
      );
      ref.invalidate(currentUserProvider);
      if (mounted) {
        showApiSuccess(ref, l10n.profileSaved);
        context.pop();
      }
    } catch (e) {
      showApiError(ref, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);

    return SafedScaffold(
      appBar: AppBar(title: Text(l10n.profileEditTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            TextFormField(
              controller: _firstNameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.profileFirstName,
              ),
              validator: (v) {
                final first = v?.trim() ?? '';
                final last = _lastNameCtrl.text.trim();
                if (first.isEmpty && last.isEmpty) {
                  return l10n.profileNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.profileLastName,
              ),
              validator: (v) {
                final last = v?.trim() ?? '';
                final first = _firstNameCtrl.text.trim();
                if (first.isEmpty && last.isEmpty) {
                  return l10n.profileNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.profileSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
