import 'package:web/web.dart' as web;

void setBrowserItem(String key, String value) {
  web.window.localStorage.setItem(key, value);
}

String? getBrowserItem(String key) {
  return web.window.localStorage.getItem(key);
}

void removeBrowserItem(String key) {
  web.window.localStorage.removeItem(key);
}

String getBrowserProtocol() {
  return web.window.location.protocol;
}