import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/rules_screen.dart';
import 'screens/tests_screen.dart';

void main() {
  runApp(const RefereeApp());
}

class RefereeApp extends StatelessWidget {
  const RefereeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(
      Theme.of(context).textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.25,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.25,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.25,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RefereeApp',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blue[600]!,
          secondary: Colors.blue[400]!,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF5F6FA),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.grey[800]),
          titleTextStyle: textTheme.displaySmall?.copyWith(
            color: Colors.grey[800],
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return textTheme.labelMedium?.copyWith(
                color: Colors.blue[600],
              );
            }
            return textTheme.labelMedium?.copyWith(
              color: Colors.grey[600],
            );
          }),
        ),
        textTheme: textTheme,
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RulesScreen(),
    const TestsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          height: 65,
          selectedIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey[600],
              ),
              label: 'Главная',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.menu_book_outlined,
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey[600],
              ),
              label: 'Правила',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.quiz_outlined,
                color: _selectedIndex == 2 ? Colors.blue : Colors.grey[600],
              ),
              label: 'Тесты',
            ),
          ],
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    );
  }
}
