import 'package:flutter_test/flutter_test.dart';
import 'package:mandal_capital/common/html_content.dart';

void main() {
  test('extracts .terms elements across contracts, skipping nested', () {
    final data = {
      'contracts': [
        {
          'intro': 'Оршил',
          'sections': [
            {'content': '8.1\tТекст\n<div class="terms">A<p class="terms">B</p></div>'},
            {'content': '<span class="x terms">C</span> бусад'},
            {'content': '<b>terms гэдэг үг ч class биш</b>'},
          ],
        },
      ],
    };
    final html = extractHtmlByClass(data, 'terms');
    expect(html, '<div class="terms">A<p class="terms">B</p></div>\n'
        '<span class="x terms">C</span>');
  });

  test('returns null when no .terms', () {
    expect(extractHtmlByClass({'a': '<b>x</b>'}, 'terms'), isNull);
  });

  test('prepareHtmlContent keeps tabs/newlines', () {
    expect(prepareHtmlContent('8.1\tA\n<b>B</b>\n<table>\n<tr><td>1</td></tr>\n</table>'),
        '8.1&nbsp;&nbsp;&nbsp;&nbsp;A<br><b>B</b><table><tr><td>1</td></tr></table>');
  });
}
