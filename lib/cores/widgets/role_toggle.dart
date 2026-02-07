import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../../features/lobby/model/user_role.dart';

/// Shared role toggle (Viewer/Host)
class SharedRoleToggle extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const SharedRoleToggle({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Joining As',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.slate300,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.surfaceDark,
            border: Border.all(
              color: colors.surfaceBorder,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _Option(
                role: UserRole.viewer,
                isSelected: selectedRole == UserRole.viewer,
                onTap: () => onRoleChanged(UserRole.viewer),
              ),
              _Option(
                role: UserRole.host,
                isSelected: selectedRole == UserRole.host,
                onTap: () => onRoleChanged(UserRole.host),
              ),
            ],
          ),
        ),
      ],
    );
}

class _Option extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const _Option({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? (role == UserRole.host ? colors.primary : colors.slate600)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                role == UserRole.viewer
                    ? Icons.visibility_outlined
                    : Icons.mic_outlined,
                size: 18,
                color: isSelected ? Colors.white : colors.slate400,
              ),
              const SizedBox(width: 8),
              Text(
                role.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : colors.slate400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
