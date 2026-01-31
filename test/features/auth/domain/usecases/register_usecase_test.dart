import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/auth/domain/repositories/auth_repository.dart';
import 'package:project_ease/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(
        fullName: 'fallback name',
        email: 'fallback@example.com',
        password: 'fallback123',
      ),
    );
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockRepository);
  });

  const tFullName = 'test name';
  const tEmail = 'test@gmail.com';
  const tPhoneNumber = '9877777777';
  const tPassword = 'password123';

  group('Register usecase', () {
    test('returns true when registration succeeds', () async {
      when(
        () => mockRepository.registerUser(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          phoneNumber: tPhoneNumber,
          password: tPassword,
        ),
      );

      expect(result, const Right(true));
      verify(() => mockRepository.registerUser(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('creates correct AuthEntity and passes it to repository', () async {
      AuthEntity? captured;

      when(() => mockRepository.registerUser(any())).thenAnswer((inv) {
        captured = inv.positionalArguments[0] as AuthEntity;
        return Future.value(const Right(true));
      });

      await usecase(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          phoneNumber: tPhoneNumber,
          password: tPassword,
        ),
      );

      expect(captured?.fullName, tFullName);
      expect(captured?.email, tEmail);
      expect(captured?.phoneNumber, tPhoneNumber);
      expect(captured?.password, tPassword);
      expect(captured?.authId, isNull);
    });

    test('handles null phoneNumber correctly', () async {
      AuthEntity? captured;

      when(() => mockRepository.registerUser(any())).thenAnswer((inv) {
        captured = inv.positionalArguments[0] as AuthEntity;
        return Future.value(const Right(true));
      });

      await usecase(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          phoneNumber: null,
          password: tPassword,
        ),
      );

      expect(captured?.phoneNumber, isNull);
      expect(captured?.fullName, tFullName);
      expect(captured?.email, tEmail);
      expect(captured?.password, tPassword);
    });

    test('returns ApiFailure when email already exists', () async {
      const failure = ApiFailure(message: 'Email already exists');

      when(
        () => mockRepository.registerUser(any()),
      ).thenAnswer((_) async => Left(failure));

      final result = await usecase(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          phoneNumber: tPhoneNumber,
          password: tPassword,
        ),
      );

      expect(result, Left(failure));
      verify(() => mockRepository.registerUser(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns NetworkFailure when offline', () async {
      const failure = NetworkFailure(message: 'No internet connection');

      when(
        () => mockRepository.registerUser(any()),
      ).thenAnswer((_) async => Left(failure));

      final result = await usecase(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          phoneNumber: tPhoneNumber,
          password: tPassword,
        ),
      );

      expect(result, Left(failure));
      verify(() => mockRepository.registerUser(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns LocalDatabaseFailure on local save error', () async {
      const failure = LocalDatabaseFailure(
        message: 'Failed to save user locally',
      );

      when(
        () => mockRepository.registerUser(any()),
      ).thenAnswer((_) async => Left(failure));

      final result = await usecase(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          phoneNumber: tPhoneNumber,
          password: tPassword,
        ),
      );

      expect(result, Left(failure));
      verify(() => mockRepository.registerUser(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
