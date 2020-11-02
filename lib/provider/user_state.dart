import 'package:flutter/material.dart';

// TODO: work with login
// E/flutter (26269): [ERROR:flutter/lib/ui/ui_dart_state.cc(177)] Unhandled Exception: Error: Could not find the correct Provider<UserStateProvider> above this LoginPage Widget
// E/flutter (26269): 
// E/flutter (26269): This likely happens because you used a `BuildContext` that does not include the provider

class UserStateProvider with ChangeNotifier {
  bool loginState = false;

  void changeLogin(bool state) {
    loginState = state;
    notifyListeners();
  }
}
