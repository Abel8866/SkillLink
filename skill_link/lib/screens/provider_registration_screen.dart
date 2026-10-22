import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../data/service_categories.dart';
import '../services/provider_registration_service.dart';
import '../services/image_upload_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'provider_registration_success_screen.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  const ProviderRegistrationScreen({super.key});

  @override
  State<ProviderRegistrationScreen> createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState
    extends State<ProviderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _titleController = TextEditingController();
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String? _category;
  String? _pricingUnit;
  String? _availability;
  bool _isSubmitting = false;
  XFile? _selectedImage;
  double? _uploadProgress;

  static const _pricingUnits = [
    'Per hour',
    'Per service',
    'Per session',
    'Per project',
    'Negotiable',
  ];
  static const _availabilityOptions = ['Available', 'Busy', 'Weekends only'];

  final _registrationService = ProviderRegistrationService.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _titleController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Enter your $label';
    return null;
  }

  String? _validatePhone(String? value) {
    final required = _required(value, 'phone number');
    if (required != null) return required;
    final normalized = value!.replaceAll(RegExp(r'[\s()-]'), '');
    if (!RegExp(r'^(\+251|0)?9\d{8}$').hasMatch(normalized)) {
      return 'Enter a valid Ethiopian phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateExperience(String? value) {
    final required = _required(value, 'years of experience');
    if (required != null) return required;
    final experience = int.tryParse(value!.trim());
    if (experience == null || experience < 0) {
      return 'Enter a whole number of 0 or more';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final required = _required(value, 'service description');
    if (required != null) return required;
    if (value!.trim().length < 20) {
      return 'Add at least 20 characters about your service';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (_pricingUnit == 'Negotiable' &&
        (value == null || value.trim().isEmpty)) {
      return null;
    }
    final required = _required(value, 'price');
    if (required != null) return required;
    final price = double.tryParse(value!.trim());
    if (price == null || price <= 0) return 'Enter a positive price';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null || _pricingUnit == null || _availability == null) {
      setState(() {});
      return;
    }

    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please sign in again before submitting a registration.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadProgress = null;
    });
    String? uploadedImageUrl;
    final registrationId = _registrationService.newRegistrationId();
    final registrationReference = _registrationService
        .newRegistrationReference();
    try {
      if (_selectedImage != null) {
        try {
          uploadedImageUrl = await ImageUploadService.instance.upload(
            file: _selectedImage!,
            path:
                'providerRegistrations/${user.uid}/$registrationId/profileImage',
            onProgress: (progress) {
              if (mounted) setState(() => _uploadProgress = progress);
            },
          );
        } on FirebaseException catch (error, stackTrace) {
          debugPrint(
            '[ProviderRegistration] Image upload failed '
            '(path=providerRegistrations/{uid}/$registrationId/profileImage, '
            'code=${error.code}): ${error.message ?? error}',
          );
          debugPrintStack(stackTrace: stackTrace);
          rethrow;
        }
      }
      final registration = await _registrationService.submit(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        location: _locationController.text.trim(),
        category: _category!,
        professionalTitle: _titleController.text.trim(),
        experienceYears: int.parse(_experienceController.text.trim()),
        description: _descriptionController.text.trim(),
        price: _priceController.text.trim().isEmpty
            ? null
            : double.parse(_priceController.text.trim()),
        pricingUnit: _pricingUnit!,
        availability: _availability!,
        profileImageUrl: uploadedImageUrl,
        ownerUid: user.uid,
        registrationId: registrationId,
        registrationReference: registrationReference,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              ProviderRegistrationSuccessScreen(registration: registration),
        ),
      );
    } on ProviderRegistrationPersistenceException catch (error) {
      if (uploadedImageUrl != null) {
        try {
          await ImageUploadService.instance.deleteIfPresent(uploadedImageUrl);
        } catch (cleanupError) {
          debugPrint('Provider image cleanup failed: $cleanupError');
        }
      }
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.phase == 'Firestore persistence'
                ? 'Registration could not be saved. Please try again.'
                : 'Registration could not be saved locally. Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        '[ProviderRegistration] Unexpected Firebase failure '
        '(code=${error.code}): ${error.message ?? error}',
      );
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration could not be saved. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('[ProviderRegistration] Unexpected failure: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration could not be saved. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final image = await ImageUploadService.instance.pickImage(source);
      if (image == null) return;
      await ImageUploadService.instance.validate(image);
      if (mounted) setState(() => _selectedImage = image);
    } on ImageValidationException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      debugPrint('Provider image selection failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Provider'),
        actions: [
          IconButton(
            tooltip: 'Cancel',
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Tell customers about your skills',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your registration is saved on this device and submitted securely for review. It remains pending until approved.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Profile photo (optional)'),
            _ProviderImagePicker(
              image: _selectedImage,
              onTap: _isSubmitting ? null : _pickImage,
              progress: _uploadProgress,
            ),
            const SizedBox(height: 24),
            _sectionTitle('Personal information'),
            _field(
              controller: _nameController,
              label: 'Full name',
              icon: Icons.person_outline_rounded,
              validator: (value) => _required(value, 'full name'),
            ),
            _field(
              controller: _phoneController,
              label: 'Phone number',
              hint: '+251 9XX XXX XXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            _field(
              controller: _emailController,
              label: 'Email address (optional)',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            _field(
              controller: _locationController,
              label: 'City or service location',
              icon: Icons.location_on_outlined,
              validator: (value) => _required(value, 'service location'),
            ),
            const SizedBox(height: 12),
            _sectionTitle('Professional information'),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Service category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: serviceCategoryNames
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              validator: (value) => value == null ? 'Select a category' : null,
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _category = value),
            ),
            _field(
              controller: _titleController,
              label: 'Professional title or skill',
              icon: Icons.work_outline_rounded,
              validator: (value) => _required(value, 'professional title'),
            ),
            _field(
              controller: _experienceController,
              label: 'Years of experience',
              icon: Icons.trending_up_rounded,
              keyboardType: TextInputType.number,
              validator: _validateExperience,
            ),
            _field(
              controller: _descriptionController,
              label: 'Service description',
              icon: Icons.description_outlined,
              maxLines: 4,
              validator: _validateDescription,
            ),
            _field(
              controller: _priceController,
              label: 'Price',
              hint: 'Example: 500',
              icon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validatePrice,
            ),
            DropdownButtonFormField<String>(
              initialValue: _pricingUnit,
              decoration: const InputDecoration(
                labelText: 'Pricing unit',
                prefixIcon: Icon(Icons.sell_outlined),
              ),
              items: _pricingUnits
                  .map(
                    (unit) => DropdownMenuItem(value: unit, child: Text(unit)),
                  )
                  .toList(),
              validator: (value) =>
                  value == null ? 'Select a pricing unit' : null,
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() {
                      _pricingUnit = value;
                      _formKey.currentState?.validate();
                    }),
            ),
            DropdownButtonFormField<String>(
              initialValue: _availability,
              decoration: const InputDecoration(
                labelText: 'Availability',
                prefixIcon: Icon(Icons.schedule_outlined),
              ),
              items: _availabilityOptions
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              validator: (value) =>
                  value == null ? 'Select your availability' : null,
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _availability = value),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Your phone number and email are kept private and are not shown as public provider information.',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Registration'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          alignLabelWithHint: maxLines > 1,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        textInputAction: maxLines > 1
            ? TextInputAction.newline
            : TextInputAction.next,
      ),
    );
  }
}

class _ProviderImagePicker extends StatelessWidget {
  const _ProviderImagePicker({
    required this.image,
    required this.onTap,
    required this.progress,
  });

  final XFile? image;
  final VoidCallback? onTap;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              child: image == null
                  ? const Icon(Icons.add_a_photo_outlined)
                  : FutureBuilder<Uint8List>(
                      future: image!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        return ClipOval(
                          child: Image.memory(
                            snapshot.data!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                progress == null
                    ? (image == null
                          ? 'Add a professional photo'
                          : 'Photo selected')
                    : 'Uploading ${(progress! * 100).round()}%',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
