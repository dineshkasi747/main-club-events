import 'package:flutter_test/flutter_test.dart';
import 'package:college_clubs_mobile/providers/app_state.dart';

void main() {
  test('Test roll number branch and year parsing', () {
    final appState = AppState();

    final res1 = appState.parseRollNumberDetails('324108883001');
    expect(res1['branch'], 'CSE with Data Science');
    expect(res1['year'], '3rd Year');
    expect(res1['yearOfPassing'], 2028);

    final res2 = appState.parseRollNumberDetails('3214103382001');
    expect(res2['branch'], 'CSE with AI & ML');
    expect(res2['year'], '3rd Year');
    expect(res2['yearOfPassing'], 2028);

    final res3 = appState.parseRollNumberDetails('324108882001');
    expect(res3['branch'], 'CSE with AI & ML');
    expect(res3['year'], '3rd Year');
    expect(res3['yearOfPassing'], 2028);

    final res4 = appState.parseRollNumberDetails('323108802001');
    expect(res4['branch'], 'Chemical Engineering');
    expect(res4['year'], '4th Year');
    expect(res4['yearOfPassing'], 2027);

    final res5 = appState.parseRollNumberDetails('325108812001');
    expect(res5['branch'], 'Electronics & Communication Engineering');
    expect(res5['year'], '2nd Year');
    expect(res5['yearOfPassing'], 2029);

    final res6 = appState.parseRollNumberDetails('326108814001');
    expect(res6['branch'], 'Electrical & Electronics Engineering');
    expect(res6['year'], '1st Year');
    expect(res6['yearOfPassing'], 2030);
  });
}
