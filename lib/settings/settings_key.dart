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