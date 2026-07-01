import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hostel_booking/core/services/storage/storage_service.dart';
import 'package:hostel_booking/features/auth/domain/entities/auth_entity.dart';
import 'package:hostel_booking/features/auth/domain/usecases/login_usecase.dart';
import 'package:hostel_booking/features/auth/domain/usecases/logout_usecase.dart';
import 'package:hostel_booking/features/auth/domain/usecases/register_usecase.dart';
import 'package:hostel_booking/features/auth/domain/usecases/upload_profile_picture_usecase.dart';
import 'package:hostel_booking/features/auth/presentation/pages/login_page.dart';
import 'package:hostel_booking/features/auth/presentation/view_model/auth_state.dart';
import 'package:hostel_booking/features/auth/presentation/view_model/auth_view_model.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────────
class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockUploadProfilePictureUseCase extends Mock
    implements UploadProfilePictureUseCase {}

class FakeLoginParams extends Fake implements LoginParams {}

class FakeAuthEntity extends Fake implements AuthEntity {}

class FakeUploadProfilePictureParams extends Fake
    implements UploadProfilePictureParams {}

// ─── Helpers ──────────────────────────────────────────────────────────────────
Future<AuthNotifier> _buildNotifier({
  required MockLoginUseCase login,
  required MockRegisterUseCase register,
  required MockLogoutUseCase logout,
  required MockUploadProfilePictureUseCase upload,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs: prefs);
  return AuthNotifier(
    loginUseCase: login,
    registerUseCase: register,
    logoutUseCase: logout,
    uploadProfilePictureUseCase: upload,
    storageService: storage,
  );
}

Widget _buildApp(AuthNotifier notifier) => ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith((ref) => notifier),
      ],
      child: const MaterialApp(home: LoginPage()),
    );

void main() {
  late MockLoginUseCase mockLogin;
  late MockRegisterUseCase mockRegister;
  late MockLogoutUseCase mockLogout;
  late MockUploadProfilePictureUseCase mockUpload;

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeAuthEntity());
    registerFallbackValue(FakeUploadProfilePictureParams());
  });

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockRegister = MockRegisterUseCase();
    mockLogout = MockLogoutUseCase();
    mockUpload = MockUploadProfilePictureUseCase();
  });

  // ── Widget Test 1 ─────────────────────────────────────────────────────────
  testWidgets(
    'WT-1: renders email and password text fields',
    (tester) async {
      final notifier = await _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
      );
      await tester.pumpWidget(_buildApp(notifier));

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    },
  );

  // ── Widget Test 2 ─────────────────────────────────────────────────────────
  testWidgets(
    'WT-2: renders Login button with correct label',
    (tester) async {
      final notifier = await _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
      );
      await tester.pumpWidget(_buildApp(notifier));

      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    },
  );

  // ── Widget Test 3 ─────────────────────────────────────────────────────────
  testWidgets(
    'WT-3: shows SnackBar when both fields are empty and Login tapped',
    (tester) async {
      final notifier = await _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
      );
      await tester.pumpWidget(_buildApp(notifier));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Please fill all fields'), findsOneWidget);
    },
  );

  // ── Widget Test 4 ─────────────────────────────────────────────────────────
  testWidgets(
    'WT-4: shows CircularProgressIndicator when isLoading is true',
    (tester) async {
      final notifier = await _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
      );
      // Drive state into loading manually
      // ignore: invalid_use_of_protected_member
      notifier.state = const AuthState(isLoading: true);

      await tester.pumpWidget(_buildApp(notifier));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  // ── Widget Test 5 ─────────────────────────────────────────────────────────
  testWidgets(
    'WT-5: Login button is disabled (onPressed == null) when isLoading is true',
    (tester) async {
      final notifier = await _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
      );
      // ignore: invalid_use_of_protected_member
      notifier.state = const AuthState(isLoading: true);

      await tester.pumpWidget(_buildApp(notifier));
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    },
  );
}
