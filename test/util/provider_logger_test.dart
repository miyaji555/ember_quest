import 'package:flutter_template/util/provider_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  group('ProviderLogger', () {
    test('各種ログが出力されても問題ないはず', () {
      final container = ProviderContainer(
        observers: [
          ProviderLogger(),
        ],
      );

      final textProvider = StateProvider.autoDispose<String>(
        (ref) => 'hoge',
        name: 'textProvider',
      );
      container.read(textProvider);
      container.read(textProvider.notifier).state = 'foo';

      final errorProvider = Provider(
        (ref) => throw Exception(),
        name: 'errorProvider',
      );
      try {
        container.read(errorProvider);
      } on Exception catch (_) {
        // do nothing
      }
    });
  });
}
