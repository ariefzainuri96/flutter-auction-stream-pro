import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../utils/navigation_service.dart';

final isBroadcastingProvider = StateProvider<bool>((ref) => false);

class BaseProviderView<T extends Notifier<K>, K> extends ConsumerWidget {
  final NotifierProvider<T, K> provider;
  final Widget Function(BuildContext, K data, T vm) builder;
  final PreferredSizeWidget Function(T vm, K data)? appBar;
  final bool extendBodyBehindAppBar;
  final bool useSafeArea;
  final Future<bool> Function(T vm, K data)? onPop;

  const BaseProviderView({
    super.key,
    required this.provider,
    this.appBar,
    required this.builder,
    this.extendBodyBehindAppBar = false,
    this.useSafeArea = true,
    this.onPop,
  });

  Widget _builder(WidgetRef ref, BuildContext context, T vm, K data) =>
      builder(context, data, vm);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var vm = ref.read(provider.notifier);
    var data = ref.watch(provider);

    return _buildScreenContent(context, vm, data, ref);
  }

  Widget _buildScreenContent(
    BuildContext context,
    T vm,
    K data,
    WidgetRef ref,
  ) =>
      GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: PopScope(
          canPop: onPop == null, // If `onPop` is null, allow pop by default
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            if (onPop != null) {
              final shouldPop = await onPop!(vm, data);

              if (shouldPop && context.mounted) {
                NavigationService.pop(callback: result);
              }
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: appBar?.call(vm, data),
            extendBodyBehindAppBar: extendBodyBehindAppBar,
            body: Stack(
              children: [
                useSafeArea
                    ? SafeArea(
                        child: _builder(ref, context, vm, data),
                      )
                    : _builder(ref, context, vm, data),
              ],
            ),
          ),
        ),
      );
}
