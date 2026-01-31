import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/auth/domain/usecases/login_usecase.dart';
import 'package:project_ease/features/auth/domain/usecases/register_usecase.dart';
import 'package:project_ease/features/auth/presentation/state/auth_state.dart';
import 'package:project_ease/features/auth/presentation/view_model/auth_view_model.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;

  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const RegisterUsecaseParams(
        fullName: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback123',
      ),
    );
    registerFallbackValue(
      const LoginUsecaseParams(
        email: 'fallback@email.com',
        password: 'fallback123',
      ),
    );
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final tAuthEntity = AuthEntity(
    fullName: 'test user',
    email: 'test@gmail.com',
    phoneNumber: '9877777777',
  );

  group('AuthViewModel', () {
    group('initial state', () {
      test('has correct initial values', () {
        final state = container.read(authViewModelProvider);

        expect(state.status, AuthStatus.initial);
        expect(state.authEntity, isNull);
        expect(state.errorMessage, isNull);
      });
    });

    group('register', () {
      test('emits registered state on success', () async {
        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => const Right(true));

        final notifier = container.read(authViewModelProvider.notifier);

        await notifier.register(
          fullName: 'John Doe',
          email: 'john@example.com',
          password: 'pass1234',
          phoneNumber: '1234567890',
        );

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.registered);
        expect(state.errorMessage, isNull);
        verify(() => mockRegisterUsecase(any())).called(1);
      });

      test('emits error state when registration fails', () async {
        const failure = ApiFailure(message: 'Email already in use');
        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => Left(failure));

        final notifier = container.read(authViewModelProvider.notifier);

        await notifier.register(
          fullName: 'John Doe',
          email: 'john@example.com',
          password: 'pass1234',
        );

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Email already in use');
        expect(state.authEntity, isNull);
        verify(() => mockRegisterUsecase(any())).called(1);
      });

      test('passes correct parameters to register usecase', () async {
        RegisterUsecaseParams? captured;

        when(() => mockRegisterUsecase(any())).thenAnswer((inv) {
          captured = inv.positionalArguments[0] as RegisterUsecaseParams;
          return Future.value(const Right(true));
        });

        final notifier = container.read(authViewModelProvider.notifier);

        await notifier.register(
          fullName: 'Alice Smith',
          email: 'alice@company.com',
          password: 'secret99',
          phoneNumber: '555-1234',
        );

        expect(captured?.fullName, 'Alice Smith');
        expect(captured?.email, 'alice@company.com');
        expect(captured?.password, 'secret99');
        expect(captured?.phoneNumber, '555-1234');
      });
    });

    group('login', () {
      test('emits authenticated state with entity on success', () async {
        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => Right(tAuthEntity));

        final notifier = container.read(authViewModelProvider.notifier);

        await notifier.login(
          email: 'test@example.com',
          password: 'correctpass',
        );

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.authEntity, tAuthEntity);
        expect(state.errorMessage, isNull);
        verify(() => mockLoginUsecase(any())).called(1);
      });

      test('emits error state when login fails', () async {
        const failure = ApiFailure(message: 'Wrong password');
        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => Left(failure));

        final notifier = container.read(authViewModelProvider.notifier);

        await notifier.login(email: 'test@example.com', password: 'wrong');

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Wrong password');
        expect(state.authEntity, isNull);
        verify(() => mockLoginUsecase(any())).called(1);
      });

      test('forwards correct email/password to login usecase', () async {
        LoginUsecaseParams? captured;

        when(() => mockLoginUsecase(any())).thenAnswer((inv) {
          captured = inv.positionalArguments[0] as LoginUsecaseParams;
          return Future.value(Right(tAuthEntity));
        });

        final notifier = container.read(authViewModelProvider.notifier);

        await notifier.login(
          email: 'user@domain.com',
          password: 'my!secret@2025',
        );

        expect(captured?.email, 'user@domain.com');
        expect(captured?.password, 'my!secret@2025');
      });
    });
  });
}
