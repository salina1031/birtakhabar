import 'package:birtakhabar/app.dart';
import 'package:birtakhabar/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BirtaKhabar app boots to the splash screen', (tester) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await tester.pumpWidget(const BirtaKhabarApp());

    expect(find.text('BirtaKhabar'), findsOneWidget);
    expect(find.text("Birtamode's local news, in real time."), findsOneWidget);
  });
}
