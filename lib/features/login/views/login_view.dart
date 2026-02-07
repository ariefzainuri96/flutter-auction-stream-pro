import 'package:flutter/material.dart';
import '../../../cores/base/base_provider_view.dart';
import '../../../cores/constants/colors.dart';
import '../../../cores/constants/enums/page_state.dart';
import '../../../cores/constants/text_theme.dart';
import '../../../cores/utils/widget_extension.dart';
import '../../../cores/widgets/buttons/button.dart';
import '../../../cores/widgets/custom_text_field.dart';
import '../../../cores/widgets/text_app_bar.dart';
import '../providers/login_provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) => BaseProviderView(
        provider: loginProvider,
        appBar: (_, __) => const TextAppBar(
          title: 'Login',
          isCenterTitle: true,
          shouldShowLeading: false,
        ),
        builder: _buildScreen,
      );

  Widget _buildScreen(
    BuildContext context,
    LoginNotifierData data,
    LoginNotifier vm,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang',
              style: textTheme.font10Bold.copyWith(fontSize: 28),
            ).padOnly(bottom: 12, top: 6),
            CustomTextField(
              hint: 'Enter your username...',
              labelText: 'Username',
              showAsterisk: true,
              filledColor: colors.grey2,
              onChanged: (value) {
                final updated = data.request.copyWith(username: value);
                vm.updateRequest(updated);
              },
            ).padOnly(bottom: 12),
            CustomTextField(
              hint: 'Enter your password...',
              labelText: 'Password',
              showAsterisk: true,
              filledColor: colors.grey2,
              obscureText: true,
              onChanged: (value) {
                final updated = data.request.copyWith(password: value);
                vm.updateRequest(updated);
              },
            ).padSymmetric(vertical: 12),
            const Spacer(),
            Button(
              width: double.infinity,
              isLoading: data.loginState == PageState.loading,
              text: 'Masuk',
              onPressed: data.request.isFilled()
                  ? () {
                      vm.login();
                    }
                  : null,
            ).padSymmetric(vertical: 12),
            const SizedBox(height: 16),
          ],
        ),
      );
}
