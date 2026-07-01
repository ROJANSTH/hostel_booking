import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hostel_booking/core/error/failures.dart';
import 'package:hostel_booking/features/auth/domain/entities/auth_entity.dart';
import 'package:hostel_booking/features/auth/domain/usecases/login_usecase.dart';
import 'package:hostel_booking/features/auth/domain/usecases/logout_usecase.dart';
import 'package:hostel_booking/features/auth/domain/usecases/register_usecase.dart';
import 'package:hostel_booking/features/auth/domain/usecases/upload_profile_picture_usecase.dart';
import 'package:hostel_booking/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:hostel_booking/core/services/storage/storage_service.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────
class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockUploadProfilePictureUseCase extends Mock
    implements UploadProfilePictureUseCase {}

// ─── Fake StorageService ──────────────────────────────────────────────────────
/// Uses SharedPreferences.setMockInitialValues to back StorageService
/// without hitting the real disk.
class FakeStorageService extends StorageService {
  FakeStorageService(SharedPreferences prefs) : super(prefs: prefs);

  @override
  AuthEntity? getSavedUser() => null; // no persisted user for fresh tests
}

// ─── Fallback values ──────────────────────────────────────────────────────────
class FakeLoginParams extends Fake implements LoginParams {}

class FakeAuthEntity extends Fake implements AuthEntity {}

class FakeUploadProfilePictureParams extends Fake
    implements UploadProfilePictureParams {}

// ─── Test data ────────────────────────────────────────────────────────────────
const tEmail = 'user@example.com';
const tPassword = 'pass1234';

const tAuthEntity = AuthEntity(
  id: '42',
  name: 'Jane Doe',
  email: tEmail,
  password: tPassword,
  phone: '9800000099',
);

// ─── Helper ───────────────────────────────────────────────────────────────────
AuthNotifier _buildNotifier({
  required MockLoginUseCase login,
  required MockRegisterUseCase register,
  required MockLogoutUseCase logout,
  required MockUploadProfilePictureUseCase upload,
  required FakeStorageService storage,
}) =>
    AuthNotifier(
      loginUseCase: login,
      registerUseCase: register,
      logoutUseCase: logout,
      uploadProfilePictureUseCase: upload,
      storageService: storage,
    );

void main() {
  late MockLoginUseCase mockLogin;
  late MockRegisterUseCase mockRegister;
  late MockLogoutUseCase mockLogout;
  late MockUploadProfilePictureUseCase mockUpload;
  late FakeStorageService fakeStorage;

  setUpAll(() {
    // Register fallback values for mocktail argument matchers
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeAuthEntity());
    registerFallbackValue(FakeUploadProfilePictureParams());
  });

  setUp(() async {
    // Provide an empty SharedPreferences backing store
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    mockLogin = MockLoginUseCase();
    mockRegister = MockRegisterUseCase();
    mockLogout = MockLogoutUseCase();
    mockUpload = MockUploadProfilePictureUseCase();
    fakeStorage = FakeStorageService(prefs);
  });

  // ── ViewModel Test 1 ──────────────────────────────────────────────────────
  test(
    'VM-1: initial state has isLoading=false, isSuccess=false, user=null',
    () {
      final notifier = _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
        storage: fakeStorage,
      );

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.isSuccess, isFalse);
      expect(notifier.state.user, isNull);
      expect(notifier.state.error, isNull);
    },
  );

  // ── ViewModel Test 2 ──────────────────────────────────────────────────────
  test(
    'VM-2: login success updates state with user and isSuccess=true',
    () async {
      when(() => mockLogin(any()))
          .thenAnswer((_) async => const Right(tAuthEntity));

      final notifier = _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
        storage: fakeStorage,
      );

      await notifier.login(tEmail, tPassword);

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.isSuccess, isTrue);
      expect(notifier.state.user, equals(tAuthEntity));
      expect(notifier.state.error, isNull);
    },
  );

  // ── ViewModel Test 3 ──────────────────────────────────────────────────────
  test(
    'VM-3: login failure updates state with error message',
    () async {
      const tFailure = ServerFailure('Invalid credentials');
      when(() => mockLogin(any()))
          .thenAnswer((_) async => const Left(tFailure));

      final notifier = _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
        storage: fakeStorage,
      );

      await notifier.login(tEmail, tPassword);

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.isSuccess, isFalse);
      expect(notifier.state.user, isNull);
      expect(notifier.state.error, equals('Invalid credentials'));
    },
  );

  // ── ViewModel Test 4 ──────────────────────────────────────────────────────
  test(
    'VM-4: register success sets isSuccess=true',
    () async {
      when(() => mockRegister(any()))
          .thenAnswer((_) async => const Right(true));

      final notifier = _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
        storage: fakeStorage,
      );

      await notifier.register(tAuthEntity);

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.isSuccess, isTrue);
      expect(notifier.state.error, isNull);
    },
  );

  // ── ViewModel Test 5 ──────────────────────────────────────────────────────
  test(
    'VM-5: logout success resets AuthState to initial (no user, no error)',
    () async {
      // First, set up state as if user is logged in
      when(() => mockLogin(any()))
          .thenAnswer((_) async => const Right(tAuthEntity));
      when(() => mockLogout(any())).thenAnswer((_) async => const Right(true));

      final notifier = _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
        storage: fakeStorage,
      );

      await notifier.login(tEmail, tPassword);
      expect(notifier.state.user, equals(tAuthEntity));

      // Now logout
      await notifier.logout(tEmail);

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.isSuccess, isFalse);
      expect(notifier.state.user, isNull);
      expect(notifier.state.error, isNull);
    },
  );
}
