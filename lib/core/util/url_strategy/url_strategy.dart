import 'nonweb_url_strategy.dart'
    if (dart.library.html) 'package:flutter_web_plugins/flutter_web_plugins.dart'
    as plugins;

void usePathUrlStrategy() {
  plugins.usePathUrlStrategy();
}
