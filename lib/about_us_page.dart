import 'package:flutter/material.dart';

import 'gradient_background.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Travel Advisor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Travel Advisor is your pocket companion for respectful and confident journeys. '
                      'Browse curated etiquette and travel tips for destinations around the world, '
                      'save favorites, and learn how to make every trip smoother and more culturally aware.',
                      style: TextStyle(height: 1.4),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'We focus on concise, trustworthy guidance so you can immerse yourself in new places '
                      'with confidence and kindness.',
                      style: TextStyle(height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
