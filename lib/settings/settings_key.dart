abstract class SettingsKey<T> {
  final String key;
  final T defaultValue;

  const SettingsKey(this.key, this.defaultValue);

  T parse(String value);
  String serialize(T value);
}

class StringSettingsKey extends SettingsKey<String> {
  const StringSettingsKey(super.key, super.defaultValue);

  @override
  String parse(String value) => value;

  @override
  String serialize(String value) => value;
}

class BoolSettingsKey extends SettingsKey<bool> {
  const BoolSettingsKey(super.key, super.defaultValue);

  @override
  bool parse(String value) => value.toLowerCase() == 'true';

  @override
  String serialize(bool value) => value.toString();
}

class IntSettingsKey extends SettingsKey<int> {
  const IntSettingsKey(super.key, super.defaultValue);

  @override
  int parse(String value) => int.tryParse(value) ?? defaultValue;

  @override
  String serialize(int value) => value.toString();
}

class EnumSettingsKey<T> extends SettingsKey<T> {
  final List<T> values;

  const EnumSettingsKey(super.key, super.defaultValue, this.values);

  @override
  T parse(String value) {
    return values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => defaultValue,
    );
  }

  @override
  String serialize(T value) => value.toString().split('.').last;
}

class Entry<K, V> {
  final K key;
  V value;

  Entry(this.key, this.value);
}

class OrderedMapSettingsKey extends SettingsKey<List<Entry<String, String>>> {
  const OrderedMapSettingsKey(super.key, super.defaultValue);

  @override
  List<Entry<String, String>> parse(String value) {
    if (value.isEmpty) return [];
    return value.split(',').map((e) {
      final parts = e.split(':');
      if (parts.length != 2) return Entry('', '');
      return Entry(parts[0], parts[1]);
    }).where((e) => e.key.isNotEmpty).toList();
  }

  @override
  String serialize(List<Entry<String, String>> value) {
    return value.map((e) => '${e.key}:${e.value}').join(',');
  }
}