// lib/shared/widgets/password_validation_widget.dart
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/secure_password_generator.dart';

class PasswordValidationWidget extends StatelessWidget {
  final TextEditingController passwordController;
  final VoidCallback onRegeneratePassword;
  final bool showPasswordRequirements;
  final String? helperText;

  const PasswordValidationWidget({
    Key? key,
    required this.passwordController,
    required this.onRegeneratePassword,
    this.showPasswordRequirements = true,
    this.helperText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Password input field with validation
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: passwordController,
          builder: (context, value, child) {
            final validation = SecurePasswordGenerator.validatePasswordForUI(value.text);

            return TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password temporanea',
                helperText: helperText ?? 'L\'utente dovrà cambiarla al primo accesso',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Regenerate button
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: onRegeneratePassword,
                      tooltip: 'Genera nuova password sicura',
                    ),
                    // Info button
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => _showPasswordRequirements(context),
                      tooltip: 'Requisiti password',
                    ),
                  ],
                ),
                // Dynamic border color based on validation
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: validation['isValid'] ? Colors.green : Colors.orange,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: validation['isValid'] ? Colors.green : Colors.orange,
                    width: 2,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Real-time validation indicator
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: passwordController,
          builder: (context, value, child) {
            final validation = SecurePasswordGenerator.validatePasswordForUI(value.text);

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: validation['isValid']
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: validation['isValid']
                      ? Colors.green.withOpacity(0.3)
                      : Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main status
                  Row(
                    children: [
                      Icon(
                        validation['isValid'] ? Icons.security : Icons.warning,
                        color: validation['isValid'] ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          validation['isValid']
                              ? 'La password soddisfa tutti i requisiti di sicurezza'
                              : validation['errorMessage'] ?? 'Validazione password non riuscita',
                          style: TextStyle(
                            fontSize: 14,
                            color: validation['isValid'] ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (showPasswordRequirements) ...[
                    const SizedBox(height: 8),
                    // Requirements checklist
                    _buildRequirementsList(validation['requirements']),
                  ],

                  if (validation['isValid']) ...[
                    const SizedBox(height: 8),
                    // Strength indicator
                    Row(
                      children: [
                        const Text(
                          'Robustezza: ',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStrengthColor(validation['strength']).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getStrengthColor(validation['strength']).withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            validation['strengthDescription'],
                            style: TextStyle(
                              fontSize: 11,
                              color: _getStrengthColor(validation['strength']),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRequirementsList(Map<String, bool> requirements) {
    final requirementsList = [
      {'key': 'minLength', 'label': 'Almeno 8 caratteri'},
      {'key': 'lowercase', 'label': 'Contiene una lettera minuscola'},
      {'key': 'uppercase', 'label': 'Contiene una lettera maiuscola'},
      {'key': 'number', 'label': 'Contiene un numero'},
      {'key': 'specialChar', 'label': 'Contiene un carattere speciale (@\$!%*?&)'},
    ];

    return Column(
      children: requirementsList.map((req) {
        final isValid = requirements[req['key']] ?? false;
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isValid ? Colors.green : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                req['label']!,
                style: TextStyle(
                  fontSize: 12,
                  color: isValid ? Colors.green : Colors.grey[600],
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStrengthColor(int strength) {
    if (strength >= 80) return Colors.green;
    if (strength >= 60) return Colors.lightGreen;
    if (strength >= 40) return Colors.orange;
    return Colors.red;
  }

  void _showPasswordRequirements(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: CustomColors.verdeAbisso),
            SizedBox(width: 8),
            Text(
              'Requisiti di sicurezza della password',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                color: CustomColors.verdeAbisso,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Per la massima sicurezza, tutte le password temporanee devono soddisfare questi requisiti:',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              '✓ Almeno 8 caratteri',
              '✓ Contiene lettere minuscole (a-z)',
              '✓ Contiene lettere maiuscole (A-Z)',
              '✓ Contiene numeri (0-9)',
              '✓ Contiene caratteri speciali (@\$!%*?&)',
            ].map((req) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      req.substring(2), // Remove the ✓ symbol
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Per maggiore sicurezza, l\'utente dovrà cambiare questa password al primo accesso.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Ho capito',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function for consistent password validation across the app
class PasswordValidationHelper {
  /// Validate password and show error if invalid
  static bool validateAndShowError(BuildContext context, String password) {
    final validation = SecurePasswordGenerator.validatePasswordForUI(password);

    if (!validation['isValid']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  validation['errorMessage'] ?? 'La password non soddisfa i requisiti di sicurezza',
                  style: const TextStyle(fontFamily: 'Montserrat'),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  /// Generate and validate password - unified helper
  static String generateValidatedPassword({int length = 12}) {
    final password = SecurePasswordGenerator.generateSecureTemporaryPassword(length: length);
    final validation = SecurePasswordGenerator.validatePasswordForUI(password);

    if (!validation['isValid']) {
      throw StateError('Generated password failed validation: ${validation['errorMessage']}');
    }

    return password;
  }
}