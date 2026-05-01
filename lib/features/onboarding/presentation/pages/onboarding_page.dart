import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    Get.put(OnboardingController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Obx(() => AnimatedOpacity(
                      opacity: controller.isLastPage ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: controller.isLastPage ? null : controller.completeOnboarding,
                        child: Text(
                          'تخطي',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )),
              ),
            ),

            // Slides
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: controller.slides.length,
                onPageChanged: (index) => controller.currentPage.value = index,
                itemBuilder: (context, index) {
                  final slide = controller.slides[index];
                  return OnboardingSlide(
                    title: slide['title']!,
                    description: slide['description']!,
                    lottieAsset: slide['lottie']!,
                  );
                },
              ),
            ),

            // Indicator + Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: pageController,
                    count: controller.slides.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Theme.of(context).colorScheme.primary,
                      dotColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!controller.isLastPage) {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              controller.completeOnboarding();
                            }
                          },
                          child: Text(
                            controller.isLastPage ? 'ابدأ الآن' : 'التالي',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
