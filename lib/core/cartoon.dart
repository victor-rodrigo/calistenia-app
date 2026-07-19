import 'package:flutter/material.dart';

import 'theme.dart';

/// Card no estilo "adesivo": contorno de tinta grosso + sombra dura deslocada.
class StickerCard extends StatelessWidget {
  const StickerCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = AppColors.card,
    this.radius = 20,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.ink, width: 2.5),
      boxShadow: const [
        BoxShadow(color: AppColors.ink, offset: Offset(4, 5)),
      ],
    );

    final content = Padding(padding: padding, child: child);
    if (onTap == null) {
      return Container(decoration: decoration, child: content);
    }
    return DecoratedBox(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}

/// Ícone dentro de um quadrado arredondado colorido, com contorno de tinta.
class CartoonBadge extends StatelessWidget {
  const CartoonBadge({
    super.key,
    required this.icon,
    this.color = AppColors.mustard,
    this.size = 46,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final onColor =
        color == AppColors.mustard ? AppColors.ink : AppColors.card;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 2.5),
        boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(2, 2))],
      ),
      child: Icon(icon, color: onColor, size: size * 0.52),
    );
  }
}

/// Botão circular chunky (usado para "iniciar treino").
class CartoonRoundButton extends StatelessWidget {
  const CartoonRoundButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = AppColors.red,
    this.size = 46,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: 2.5),
          boxShadow: const [
            BoxShadow(color: AppColors.ink, offset: Offset(3, 3)),
          ],
        ),
        child: Icon(icon, color: AppColors.card, size: size * 0.5),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
