import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class MyKeyboardListenerWidget extends StatelessWidget {
  final Function proceed;
  final Widget child;
  const MyKeyboardListenerWidget({
    Key key,
    @required this.proceed,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (event) {
        if (event is RawKeyDownEvent &&
            event.isKeyPressed(LogicalKeyboardKey.enter)) {
          proceed();
        }
      },
      child: child,
    );
  }
}
