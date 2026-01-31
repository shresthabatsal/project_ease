import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_ease/core/services/storage/user_service_session.dart';
import 'package:project_ease/features/auth/domain/usecases/register_usecase.dart';
import 'package:project_ease/features/auth/presentation/pages/login_screen.dart';
import 'package:project_ease/features/auth/presentation/pages/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

final customTextFormFieldFinder = find.byWidgetPredicate(
  (widget) => widget.toString().contains('CustomTextFormField'),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockRegisterUsecase mockRegisterUsecase;
  late MockNavigatorObserver mockNavigatorObserver;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockRegisterUsecase = MockRegisterUsecase();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
      ],
      child: MaterialApp(
        navigatorObservers: [mockNavigatorObserver],
        home: const SignupScreen(),
        routes: {'/login': (context) => const LoginScreen()},
      ),
    );
  }

  group('SignupScreen Widget Tests', () {
    testWidgets('should have all form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(customTextFormFieldFinder, findsNWidgets(5));
      expect(find.text('Full Name'), findsNWidgets(2));
      expect(find.text('Phone Number'), findsNWidgets(2));
      expect(find.text('Email'), findsNWidgets(2));
      expect(find.text('Password'), findsNWidgets(2));
      expect(find.text('Confirm Password'), findsNWidgets(2));
    });

    testWidgets('should have a sign up button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should have login link text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Login.'), findsOneWidget);
    });

    testWidgets('should have checkbox for Terms & Conditions', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('I agree to the '), findsOneWidget);
      expect(find.text('Terms & Conditions.'), findsOneWidget);
    });

    testWidgets('should have Google sign in button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('should have form with key', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets(
      'should display validation messages when form is submitted with empty fields',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final textFormFields = find.byType(TextFormField);
        expect(textFormFields, findsNWidgets(5));

        final signUpButtonFinder = find.text('Sign Up');
        await tester.ensureVisible(signUpButtonFinder);
        await tester.pumpAndSettle();

        // First check the checkbox to agree to terms
        final checkboxFinder = find.byType(Checkbox);
        await tester.ensureVisible(checkboxFinder);
        await tester.pumpAndSettle();
        await tester.tap(checkboxFinder);
        await tester.pump();

        // Now submit the form
        await tester.ensureVisible(signUpButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(signUpButtonFinder);
        await tester.pump();

        // Check for validation messages
        expect(find.text('Full name is required.'), findsOneWidget);
        expect(find.text('Phone number is required.'), findsOneWidget);
        expect(find.text('Email is required.'), findsOneWidget);
        expect(find.text('Password is required.'), findsOneWidget);
        expect(find.text('Confirm password is required.'), findsOneWidget);
      },
    );

    testWidgets('should validate phone number length requirement', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFormFields = find.byType(TextFormField);
      final signUpButtonFinder = find.text('Sign Up');

      // Check the terms checkbox first
      final checkboxFinder = find.byType(Checkbox);
      await tester.ensureVisible(checkboxFinder);
      await tester.pumpAndSettle();
      await tester.tap(checkboxFinder);
      await tester.pump();

      await tester.enterText(textFormFields.at(0), 'John Doe');
      await tester.enterText(textFormFields.at(1), '12345');

      await tester.ensureVisible(signUpButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(signUpButtonFinder);
      await tester.pump();

      expect(find.text('Phone number must be 10 digits.'), findsOneWidget);
    });

    testWidgets('should validate password minimum length requirement', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFormFields = find.byType(TextFormField);
      final signUpButtonFinder = find.text('Sign Up');

      // Check the terms checkbox first
      final checkboxFinder = find.byType(Checkbox);
      await tester.ensureVisible(checkboxFinder);
      await tester.pumpAndSettle();
      await tester.tap(checkboxFinder);
      await tester.pump();

      await tester.enterText(textFormFields.at(0), 'John Doe');
      await tester.enterText(textFormFields.at(1), '1234567890');
      await tester.enterText(textFormFields.at(3), '123');

      await tester.ensureVisible(signUpButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(signUpButtonFinder);
      await tester.pump();

      expect(
        find.text('Password must be at least 6 characters.'),
        findsOneWidget,
      );
    });

    testWidgets('should validate password confirmation', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFormFields = find.byType(TextFormField);
      final signUpButtonFinder = find.text('Sign Up');

      // Check the terms checkbox first
      final checkboxFinder = find.byType(Checkbox);
      await tester.ensureVisible(checkboxFinder);
      await tester.pumpAndSettle();
      await tester.tap(checkboxFinder);
      await tester.pump();

      await tester.enterText(textFormFields.at(3), 'password123');
      await tester.enterText(textFormFields.at(4), 'different123');

      await tester.ensureVisible(signUpButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(signUpButtonFinder);
      await tester.pump();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });

    testWidgets('should fill all form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFormFields = find.byType(TextFormField);
      expect(textFormFields, findsNWidgets(5));

      await tester.enterText(textFormFields.at(0), 'John Doe');
      await tester.enterText(textFormFields.at(1), '1234567890');
      await tester.enterText(textFormFields.at(2), 'john@example.com');
      await tester.enterText(textFormFields.at(3), 'password123');
      await tester.enterText(textFormFields.at(4), 'password123');

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('password123'), findsNWidgets(2));
    });

    testWidgets('should navigate to login screen when login link is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final loginLinkFinder = find.text('Login.');
      expect(loginLinkFinder, findsOneWidget);

      await tester.ensureVisible(loginLinkFinder);
      await tester.pumpAndSettle();

      await tester.tap(loginLinkFinder);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
