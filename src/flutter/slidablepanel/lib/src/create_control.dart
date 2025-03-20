import 'package:flet/flet.dart';

import 'slidablepanel.dart';

CreateControlFactory createControl = (CreateControlArgs args) {
  switch (args.control.type) {
    case "slidablepanel":
      return SlidablePanelControl(
        parent: args.parent,
        control: args.control,
        children: args.children,
        backend: args.backend
      );
    default:
      return null;
  }
};

void ensureInitialized() {
  // nothing to initialize
}
