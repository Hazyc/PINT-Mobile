import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkStatusWidget extends StatefulWidget {
  final Widget child;

  const NetworkStatusWidget({required this.child});

  @override
  _NetworkStatusWidgetState createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InternetStatus>(
      stream: InternetConnection().onStatusChange,
      builder: (context, snapshot) {
        final isConnected = snapshot.data == InternetStatus.connected;

        return Directionality(
          textDirection: TextDirection.ltr, // Define a direção do texto
          child: Stack(
            children: [
              widget.child,
              if (snapshot.connectionState == ConnectionState.active && !isConnected)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.red,
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Sem conexão com a Internet',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
