import 'package:ffta/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('launches into rooms and switches main sections', (tester) async {
    await tester.pumpWidget(const FlowMoneyApp());
    await tester.pumpAndSettle();

    expect(find.text('Your rooms'), findsOneWidget);
    expect(find.text('Japan Trip'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Monthly Household'),
      280,
      scrollable: find.descendant(
        of: find.byKey(const PageStorageKey('rooms-home')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Monthly Household'), findsOneWidget);

    await tester.tap(find.text('Statistics'));
    await tester.pumpAndSettle();
    expect(find.text('Spending by category'), findsOneWidget);
    expect(find.text('Day'), findsOneWidget);
    await tester.tap(find.text('Day'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Spending by member'),
      260,
      scrollable: find.descendant(
        of: find.byKey(const PageStorageKey('statistics-page')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Spending by member'), findsOneWidget);
  });

  testWidgets('room dashboard opens the category sheet from add expense', (
    tester,
  ) async {
    await tester.pumpWidget(const FlowMoneyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Japan Trip'));
    await tester.pumpAndSettle();
    expect(find.text('Total spent'), findsOneWidget);

    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a category'), findsOneWidget);
    expect(find.text('FOOD & DRINKS'), findsOneWidget);
    expect(find.text('TRANSPORT'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Transfer');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transfer').last);
    await tester.pumpAndSettle();

    expect(find.text('Transfer method'), findsOneWidget);
    expect(find.text('Transfer to'), findsOneWidget);
    expect(find.text('Bank transfer'), findsOneWidget);
    expect(find.text('Split with'), findsNothing);
    expect(find.text('Today'), findsOneWidget);

    await tester.tap(find.text('Bank transfer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('E-wallet').last);
    await tester.pumpAndSettle();
    expect(find.text('E-wallet'), findsOneWidget);
  });

  testWidgets('expense amount uses phone keypad and split options', (
    tester,
  ) async {
    await tester.pumpWidget(const FlowMoneyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Japan Trip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();

    final amountField = find.byKey(const ValueKey('expense-amount'));
    expect(amountField, findsOneWidget);
    expect(find.byType(GridView), findsNothing);
    expect(
      tester.widget<TextField>(amountField).keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );

    await tester.tap(amountField);
    await tester.pump();
    expect(tester.testTextInput.isRegistered, isTrue);
    await tester.enterText(amountField, '12x.50');
    expect(tester.widget<TextField>(amountField).controller!.text, isEmpty);
    await tester.enterText(amountField, '12.50');
    expect(tester.widget<TextField>(amountField).controller!.text, '12.50');

    await tester.tap(find.text('4 members'));
    await tester.pumpAndSettle();
    expect(find.text('Just me'), findsOneWidget);
    await tester.tap(find.text('Just me'));
    await tester.pumpAndSettle();
    expect(find.text('Just me'), findsOneWidget);
  });

  testWidgets('create room requires a name and shows copyable invite codes', (
    tester,
  ) async {
    await tester.pumpWidget(const FlowMoneyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create room'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create room').last);
    await tester.pumpAndSettle();
    expect(find.text('Give your room a name'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Weekend in Penang',
    );
    await tester.tap(find.text('Create room').last);
    await tester.pumpAndSettle();
    expect(find.text('Your room is ready'), findsOneWidget);
    expect(find.text('FAM8-K2Q'), findsOneWidget);
    expect(find.text('FLOW-72MX'), findsOneWidget);
  });

  testWidgets('join room exposes invalid room and expired invite feedback', (
    tester,
  ) async {
    await tester.pumpWidget(const FlowMoneyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Join room'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'BAD123');
    await tester.enterText(find.byType(TextFormField).at(1), 'TOKYO24');
    await tester.tap(find.text('Join room').last);
    await tester.pumpAndSettle();
    expect(
      find.text('We couldn’t find that room code. Check it and try again.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'JP4K8D');
    await tester.enterText(find.byType(TextFormField).at(1), 'EXPIRED');
    await tester.tap(find.text('Join room').last);
    await tester.pumpAndSettle();
    expect(
      find.text('This invite has expired. Ask for a new one.'),
      findsOneWidget,
    );
  });

  testWidgets('rooms home fits a narrow phone viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlowMoneyApp());
    await tester.pumpAndSettle();

    expect(find.text('Create room'), findsOneWidget);
    expect(find.text('Join room'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
