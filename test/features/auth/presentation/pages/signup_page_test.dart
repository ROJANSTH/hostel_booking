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
import 'package:hostel_booking/features/auth/presentation/pages/signup_page.dart';
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
      child: const MaterialApp(home: SignupPage()),
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

  // ── Widget Test 6 ─────────────────────────────────────────────────────────
  testWidgets(
    'WT-6: renders all five input fields (name, email, phone, password, confirm)',
    (tester) async {
      final notifier = await _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
      );
      await tester.pumpWidget(_buildApp(notifier));

      expect(find.byType(TextField), findsNWidgets(5));
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    },
  );

  // ── Widget Test 7 ─────────────────────────────────────────────────────────
  testWidgets(
    'WT-7: renders Sign Up button with correct label',
    (tester) async {
      final notifier = await _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
      );
      await tester.pumpWidget(_buildApp(notifier));

      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    },
  );

  // ── Widget Test 8 ─────────────────────────────────────────────────────────
  testWidgets(
    'WT-8: shows SnackBar "Please fill all fields" when Sign Up tapped with empty inputs',
    (tester) async {
      final notifier = await _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
      );
      await tester.pumpWidget(_buildApp(notifier));

      // Scroll Sign Up button into view (page uses SingleChildScrollView)
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Please fill all fields'), findsOneWidget);
    },
  );

  // ── Widget Test 9 ─────────────────────────────────────────────────────────
  testWidgets(
    'WT-9: shows SnackBar "Passwords do not match" when passwords differ',
    (tester) async {
      final notifier = await _buildNotifier(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        upload: mockUpload,
      );
      await tester.pumpWidget(_buildApp(notifier));

      // Fill in the fields (they are at the top, so they are visible)
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'john@example.com');
      await tester.enterText(fields.at(2), '9800000000');
      await tester.enterText(fields.at(3), 'password123');
      await tester.enterText(fields.at(4), 'mismatch456');

      // Scroll the Checkbox into view and tick it
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Scroll Sign Up button into view and tap it
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Passwords do not match'), findsOneWidget);
    },
  );

  // ── Widget Test 10 ────────────────────────────────────────────────────────
  testWidgets(
    'WT-10: shows CircularProgressIndicator and disables Sign Up button when isLoading',
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

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    },
  );
}
