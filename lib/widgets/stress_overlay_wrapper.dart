import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/wearable_provider.dart';
import 'stress_notification_card.dart';
import '../screens/companion/companion_screen.dart';

/// Wraps the entire app to provide a global banner that floats above all navigation.
class StressOverlayWrapper extends StatelessWidget {
  final Widget child;

  const StressOverlayWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main app navigator
        child,

        // The global listener overlay
        Consumer<WearableProvider>(
          builder: (context, wearableState, _) {
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutExpo,
              top: wearableState.showBanner ? 0 : -200, // Slide down or up
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: wearableState.showBanner ? 1.0 : 0.0,
                child: StressNotificationCard(
                  onDismiss: () => wearableState.hideBanner(),
                  onTap: () {
                    // Hide banner
                    wearableState.hideBanner();

                    // Navigate strictly to the companion screen across the global navigator
                    // Using the root context via a global key or standard pushing 
                    // To do this robustly without a navigator key here, we grab the highest navigator available:
                    final navigator = Navigator.of(context, rootNavigator: true);
                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) => const CompanionScreen(
                          initialContext: {
                            "context": "stress_event",
                            "message": "[SYSTEM: The user just experienced a sudden stress spike. Acknowledge this extremely gently and ask ONE simple supportive question. Do NOT mention heart rate or system data.]",
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
