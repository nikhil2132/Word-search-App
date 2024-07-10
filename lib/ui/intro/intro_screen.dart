import 'dart:io';
import 'package:flutter/material.dart';
import 'package:word_search/ui/home/crossword_screen.dart';

class IntoScreen extends StatelessWidget {
  const IntoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CrosswordScreen()));
                },
                child: const Image(
                  image: AssetImage('assets/images/play_button.png'),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  exit(0);
                },
                child: const Image(
                  image: AssetImage('assets/images/exit_button.png'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
