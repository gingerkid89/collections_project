// lib/widgets/connectivity_status_widget.dart

import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

class ConnectivityStatusWidget extends StatefulWidget {
  final Widget? child;
  final bool showWhenOnline;

  const ConnectivityStatusWidget({
    super.key,
    this.child,
    this.showWhenOnline = false,
  });

  @override
  State<ConnectivityStatusWidget> createState() => _ConnectivityStatusWidgetState();
}

class _ConnectivityStatusWidgetState extends State<ConnectivityStatusWidget> {
  ConnectivityStatus _status = ConnectivityStatus.unknown;
  late Stream<ConnectivityStatus> _connectivityStream;

  @override
  void initState() {
    super.initState();
    _status = ConnectivityService.instance.currentStatus;
    _connectivityStream = ConnectivityService.instance.connectivityStream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityStatus>(
      stream: _connectivityStream,
      initialData: _status,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectivityStatus.unknown;

        // Only show when offline or when explicitly requested to show online status
        if (status == ConnectivityStatus.online && !widget.showWhenOnline) {
          return widget.child ?? const SizedBox.shrink();
        }

        return Column(
          children: [
            _buildStatusBar(status),
            if (widget.child != null) widget.child!,
          ],
        );
      },
    );
  }

  Widget _buildStatusBar(ConnectivityStatus status) {
    Color backgroundColor;
    String message;
    IconData icon;

    switch (status) {
      case ConnectivityStatus.online:
        backgroundColor = Colors.green;
        message = 'Connected';
        icon = Icons.wifi;
        break;
      case ConnectivityStatus.limited:
        backgroundColor = Colors.orange;
        message = 'Limited connectivity - Using cached data';
        icon = Icons.wifi_protected_setup;
        break;
      case ConnectivityStatus.offline:
        backgroundColor = Colors.red;
        message = 'Offline - Using cached data';
        icon = Icons.wifi_off;
        break;
      case ConnectivityStatus.unknown:
        backgroundColor = Colors.grey;
        message = 'Checking connection...';
        icon = Icons.help_outline;
        break;
    }

    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple connectivity indicator that can be placed anywhere
class ConnectivityIndicator extends StatefulWidget {
  final double size;

  const ConnectivityIndicator({
    super.key,
    this.size = 16,
  });

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator> {
  ConnectivityStatus _status = ConnectivityStatus.unknown;
  late Stream<ConnectivityStatus> _connectivityStream;

  @override
  void initState() {
    super.initState();
    _status = ConnectivityService.instance.currentStatus;
    _connectivityStream = ConnectivityService.instance.connectivityStream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityStatus>(
      stream: _connectivityStream,
      initialData: _status,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectivityStatus.unknown;

        Color color;
        IconData icon;

        switch (status) {
          case ConnectivityStatus.online:
            color = Colors.green;
            icon = Icons.wifi;
            break;
          case ConnectivityStatus.limited:
            color = Colors.orange;
            icon = Icons.wifi_protected_setup;
            break;
          case ConnectivityStatus.offline:
            color = Colors.red;
            icon = Icons.wifi_off;
            break;
          case ConnectivityStatus.unknown:
            color = Colors.grey;
            icon = Icons.help_outline;
            break;
        }

        return Tooltip(
          message: status.description,
          child: Icon(
            icon,
            color: color,
            size: widget.size,
          ),
        );
      },
    );
  }
}