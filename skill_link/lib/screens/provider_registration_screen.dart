import 'package:flutter/material.dart';

import '../data/sample_providers.dart';
import '../models/provider_registration.dart';
import '../services/provider_registration_service.dart';
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

  static const _pricingUnits = [
    'Per hour',
    'Per service',
    'Per session',
    'Per project',
    'Negotiable',
  ];
  static const _availabilityOptions = [
    'Available',
    'Busy',
    'Weekends only',
  ];

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

    setState(() => _isSubmitting = true);
    try {
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
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              ProviderRegistrationSuccessScreen(registration: registration),
        ),
      );
    } catch (error) {
      debugPrint('Provider registration failed: $error');
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
              'This is a local prototype. Your registration will be stored on this device and remain pending review.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Service category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: serviceCategoryNames
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePrice,
            ),
            DropdownButtonFormField<String>(
              value: _pricingUnit,
              decoration: const InputDecoration(
                labelText: 'Pricing unit',
                prefixIcon: Icon(Icons.sell_outlined),
              ),
              items: _pricingUnits
                  .map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      ))
                  .toList(),
              validator: (value) => value == null ? 'Select a pricing unit' : null,
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() {
                        _pricingUnit = value;
                        _formKey.currentState?.validate();
                      }),
            ),
            DropdownButtonFormField<String>(
              value: _availability,
              decoration: const InputDecoration(
                labelText: 'Availability',
                prefixIcon: Icon(Icons.schedule_outlined),
              ),
              items: _availabilityOptions
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
        textInputAction:
            maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      ),
    );
  }
}
