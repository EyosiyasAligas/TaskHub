import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_hub/data/repository/auth_repository.dart';
import 'package:task_hub/firebase_options.dart';

import 'auth_repository_unit_test.mocks.dart';

@GenerateMocks([FirebaseAuth, FirebaseApp])
Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for testing
  when(Firebase.initializeApp()).thenAnswer((_)  async => Firebase.app());

  final mockFirebaseAuth = MockFirebaseAuth();
  final authRepository = AuthRepository(mockFirebaseAuth);

  test('test user create', () async {
    // Mock a user with the email and password for testing purposes
    await mockFirebaseAuth.createUserWithEmailAndPassword(
      email: 'eyos@gmail.com',
      password: 'test123',
    );

    // Call the signUp method in AuthRepository
    final result = await authRepository.signUp(
      email: 'eyos@gmail.com',
      password: 'test123',
    );

    // Verify that the result matches the expected output type
    expect(result, isA<Map<String, dynamic>>());
  });
}
