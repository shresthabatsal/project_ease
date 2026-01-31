import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/auth/domain/repositories/auth_repository.dart';
import 'package:project_ease/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(
        authId: 'fallback_id',
        fullName: 'Fallback User',
        email: 'fallback@gmail.com',
        phoneNumber: '9877777777',
        profilePicture: null,
      ),
    );
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepository);
  });

  const tEmail = 'test@gmail.com';
  const tPassword = 'password123';

  final tAuthEntity = AuthEntity(
    authId: '1',
    fullName: 'test name',
    email: tEmail,
    phoneNumber: '9877777777',
    profilePicture: 'profile.jpg',
  );

  group('Login usecase', () {
    test('returns AuthEntity when login succeeds', () async {
      when(
        () => mockRepository.loginUser(any(), any()),
      ).thenAnswer((_) async => Right(tAuthEntity));

      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      expect(result, Right(tAuthEntity));
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('passes correct email and password to repository', () async {
      String? capturedEmail;
      String? capturedPassword;

      when(() => mockRepository.loginUser(any(), any())).thenAnswer((inv) {
        capturedEmail = inv.positionalArguments[0] as String;
        capturedPassword = inv.positionalArguments[1] as String;
        return Future.value(Right(tAuthEntity));
      });

      await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      expect(capturedEmail, tEmail);
      expect(capturedPassword, tPassword);
    });

    test('returns ApiFailure when credentials are invalid', () async {
      const failure = ApiFailure(message: 'Invalid credentials');

      when(
        () => mockRepository.loginUser(any(), any()),
      ).thenAnswer((_) async => Left(failure));

      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      expect(result, Left(failure));
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns NetworkFailure when offline', () async {
      const failure = NetworkFailure(message: 'No internet connection');

      when(
        () => mockRepository.loginUser(any(), any()),
      ).thenAnswer((_) async => Left(failure));

      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      expect(result, Left(failure));
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns LocalDatabaseFailure when local save fails', () async {
      const failure = LocalDatabaseFailure(
        message: 'Failed to save user locally',
      );

      when(
        () => mockRepository.loginUser(any(), any()),
      ).thenAnswer((_) async => Left(failure));

      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      expect(result, Left(failure));
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('calls repository even with empty email and password', () async {
      const emptyEmail = '';
      const emptyPassword = '';

      when(() => mockRepository.loginUser(any(), any())).thenAnswer(
        (_) async =>
            const Left(ApiFailure(message: 'Email and password required')),
      );

      await usecase(
        const LoginUsecaseParams(email: emptyEmail, password: emptyPassword),
      );

      verify(
        () => mockRepository.loginUser(emptyEmail, emptyPassword),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
