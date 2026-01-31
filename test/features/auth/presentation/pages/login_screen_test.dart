import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_ease/core/services/storage/user_service_session.dart';
import 'package:project_ease/features/auth/domain/usecases/login_usecase.dart';
import 'package:project_ease/features/auth/presentation/pages/login_screen.dart';
import 'package:project_ease/features/auth/presentation/pages/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

final customTextFormFieldFinder = find.byWidgetPredicate(
  (widget) => widget.toString().contains('CustomTextFormField'),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLoginUsecase mockLoginUsecase;
  late MockNavigatorObserver mockNavigatorObserver;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockLoginUsecase = MockLoginUsecase();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
      ],
      child: MaterialApp(
        navigatorObservers: [mockNavigatorObserver],
        home: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('should have email and password text fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(customTextFormFieldFinder, findsNWidgets(2));
      expect(find.text('Email'), findsNWidgets(2));
      expect(find.text('Password'), findsNWidgets(2));
    });

    testWidgets('should have a login button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should have signup link text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text("Don’t have an account? "), findsOneWidget);
      expect(find.text('Create one.'), findsOneWidget);
    });

    testWidgets('should have checkbox for Remember me', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
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

    testWidgets('should display validation messages for empty fields', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFormFields = find.byType(TextFormField);
      expect(textFormFields, findsNWidgets(2));

      await tester.enterText(textFormFields.at(1), 'password123');

      final loginButtonFinder = find.text('Login');
      await tester.ensureVisible(loginButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(loginButtonFinder);
      await tester.pump();

      expect(find.text('Email is required.'), findsOneWidget);

      await tester.enterText(textFormFields.at(0), 'test@example.com');
      await tester.enterText(textFormFields.at(1), '');

      await tester.ensureVisible(loginButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(loginButtonFinder);
      await tester.pump();

      expect(find.text('Password is required.'), findsOneWidget);
    });

    testWidgets('should fill email and password fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFormFields = find.byType(TextFormField);
      expect(textFormFields, findsNWidgets(2));

      await tester.enterText(textFormFields.at(0), 'test@example.com');
      await tester.enterText(textFormFields.at(1), 'password123');

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('should navigate to signup screen when signup link is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final signupLinkFinder = find.text('Create one.');
      expect(signupLinkFinder, findsOneWidget);

      await tester.ensureVisible(signupLinkFinder);
      await tester.pumpAndSettle();

      await tester.tap(signupLinkFinder);
      await tester.pumpAndSettle();

      expect(find.byType(SignupScreen), findsOneWidget);
    });
  });
}
