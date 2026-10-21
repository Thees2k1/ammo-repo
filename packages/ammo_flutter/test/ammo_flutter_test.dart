import 'package:ammo_flutter/ammo_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AmmoWidgetX.padAll wraps widget in Padding', (tester) async {
    const child = Text('test');
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: child.padAll(16.0),
      ),
    );

    final paddingFinder = find.byType(Padding);
    expect(paddingFinder, findsOneWidget);

    final paddingWidget = tester.widget<Padding>(paddingFinder);
    expect(paddingWidget.padding, equals(const EdgeInsets.all(16.0)));
  });

  testWidgets('AmmoFlutterHelper.formattedText uses ammo_dart capitalize', (
    tester,
  ) async {
    final textWidget = AmmoFlutterHelper.formattedText('ammo');
    await tester.pumpWidget(
      Directionality(textDirection: TextDirection.ltr, child: textWidget),
    );

    expect(find.text('Ammo'), findsOneWidget);
  });
}
