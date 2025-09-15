import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Primary button widget following app design system
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: AppTheme.spacingS),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
}

/// Secondary button widget
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final double? height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: OutlinedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: AppTheme.spacingS),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
}

/// Emotion selector widget
class EmotionSelector extends StatelessWidget {
  final String selectedEmotion;
  final Function(String) onEmotionSelected;
  final List<EmotionOption> emotions;

  const EmotionSelector({
    super.key,
    required this.selectedEmotion,
    required this.onEmotionSelected,
    required this.emotions,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spacingS,
      runSpacing: AppTheme.spacingS,
      children: emotions.map((emotion) {
        final isSelected = selectedEmotion == emotion.name;
        return GestureDetector(
          onTap: () => onEmotionSelected(emotion.name),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.getEmotionColor(emotion.name)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(
                color: isSelected
                    ? AppTheme.getEmotionColor(emotion.name)
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emotion.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  emotion.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Emotion option data class
class EmotionOption {
  final String name;
  final String emoji;

  const EmotionOption({
    required this.name,
    required this.emoji,
  });

  static const List<EmotionOption> defaultEmotions = [
    EmotionOption(name: 'Happy', emoji: '😊'),
    EmotionOption(name: 'Sad', emoji: '😢'),
    EmotionOption(name: 'Anxious', emoji: '😰'),
    EmotionOption(name: 'Angry', emoji: '😠'),
    EmotionOption(name: 'Calm', emoji: '😌'),
    EmotionOption(name: 'Excited', emoji: '🤩'),
    EmotionOption(name: 'Tired', emoji: '😴'),
    EmotionOption(name: 'Confused', emoji: '😕'),
  ];
}

/// Intensity slider widget
class IntensitySlider extends StatelessWidget {
  final double value;
  final Function(double) onChanged;
  final String? label;

  const IntensitySlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spacingS),
        ],
        Row(
          children: [
            const Text('1', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Expanded(
              child: Slider(
                value: value,
                onChanged: onChanged,
                min: 1,
                max: 5,
                divisions: 4,
                label: _getIntensityLabel(value.round()),
                activeColor: AppTheme.primaryColor,
                inactiveColor: Colors.grey.shade300,
              ),
            ),
            const Text('5', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Center(
          child: Text(
            _getIntensityDescription(value.round()),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ),
      ],
    );
  }

  String _getIntensityLabel(int intensity) {
    switch (intensity) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Moderate';
    }
  }

  String _getIntensityDescription(int intensity) {
    switch (intensity) {
      case 1:
        return 'Barely noticeable';
      case 2:
        return 'Mild feeling';
      case 3:
        return 'Noticeable emotion';
      case 4:
        return 'Strong feeling';
      case 5:
        return 'Overwhelming emotion';
      default:
        return 'Noticeable emotion';
    }
  }
}

/// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: AppTheme.spacingM),
                        Text(
                          message!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: AppTheme.spacingL),
              PrimaryButton(
                text: actionText!,
                onPressed: onActionPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}