with open('lib/core/services/esp32_service.dart', 'r') as f:
    c = f.read()

old_code = 'final isConnectedProvider = StateProvider<bool>((ref) => false);'
new_code = '''
class IsConnectedNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool val) => state = val;
}
final isConnectedProvider = NotifierProvider<IsConnectedNotifier, bool>(IsConnectedNotifier.new);
'''

c = c.replace(old_code, new_code)
c = c.replace('ref.read(isConnectedProvider.notifier).state =', 'ref.read(isConnectedProvider.notifier).set(')
# Also fix places where state is read or written. wait, if it's set(val), we need to check how it's used.
# "ref.read(isConnectedProvider.notifier).state = true;" -> "ref.read(isConnectedProvider.notifier).set(true);"

with open('lib/core/services/esp32_service.dart', 'w') as f:
    f.write(c)
