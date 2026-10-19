import 'package:flutter_test/flutter_test.dart';

import 'package:skill_link/main.dart';

void main() {
  testWidgets('SkillLinkApp renders home shell smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SkillLinkApp());
    await tester.pump();

    expect(find.text('SkillLink'), findsOneWidget);
  });
}
