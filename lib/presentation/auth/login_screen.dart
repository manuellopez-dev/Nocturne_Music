import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../data/auth/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.07),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _AnimatedDisc()
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 40),
                  Text(
                    'Nocturne',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -2,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms)
                      .slideY(begin: 0.3),
                  const SizedBox(height: 8),
                  Text(
                    'Tu música, tu mundo',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
                  const Spacer(flex: 2),
                  _FeatureRow(
                    icon: Icons.music_note_rounded,
                    text: 'Millones de canciones',
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.offline_bolt_rounded,
                    text: 'Escucha sin conexión',
                  ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.color_lens_rounded,
                    text: 'Tema dinámico por canción',
                  ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2),
                  const Spacer(flex: 3),
                  if (authState.isLoading)
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    )
                  else
                    _GoogleLoginButton(
                      onTap: () => ref.read(authProvider.notifier).login(),
                    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),
                  const SizedBox(height: 16),
                  if (authState.error != null)
                    Text(
                      authState.error!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDisc extends StatefulWidget {
  @override
  State<_AnimatedDisc> createState() => _AnimatedDiscState();
}

class _AnimatedDiscState extends State<_AnimatedDisc>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.primaryDark,
              Colors.black,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(3, (i) {
              final size = 120.0 - (i * 30);
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                ),
              );
            }),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GoogleLoginButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 20,
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login_rounded, color: Color(0xFFB71C1C), size: 24),
            SizedBox(width: 12),
            Text(
              'Continuar con Google',
              style: TextStyle(
                color: Color(0xFF1F1F1F),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}