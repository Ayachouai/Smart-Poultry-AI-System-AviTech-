import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import 'env_charts_page.dart';
import 'home.dart' show FarmerDashboard;

class RealTimeEnvPage extends StatefulWidget {
  const RealTimeEnvPage({super.key});

  @override
  State<RealTimeEnvPage> createState() => _RealTimeEnvPageState();
}

class _RealTimeEnvPageState extends State<RealTimeEnvPage> {
  bool _isMonitoringBackend = false;
  bool _isWebSocketConnected = false;
  String _monitoringStatusText = 'Status: Monitoring Stopped. Press Start.';
  Color _statusColor = Colors.amberAccent;

  List<FlSpot> _temperatureData = [];
  List<FlSpot> _humidityData = [];
  List<FlSpot> _co2Data = [];
  List<Map<String, dynamic>> _latestReadingsForDisplay = [];

  final int _maxDataPointsOnChart = 30;
  final int _maxTextReadingsToShow = 5;

  WebSocketChannel? _webSocketChannel;
  StreamSubscription? _webSocketSubscription;

  static const String _backendIp = "192.168.0.193";
  static const String _apiBaseUrl = "http://$_backendIp:8080";
  static const String _webSocketUrl = "ws://$_backendIp:8080/ws/realtime";

  @override
  void initState() {
    super.initState();
    _checkInitialMonitoringStatus();
  }

  @override
  void dispose() {
    _disconnectWebSocket();
    super.dispose();
  }

  Future<void> _checkInitialMonitoringStatus() async {
    try {
      final response =
          await http.get(Uri.parse('$_apiBaseUrl/monitoring/status'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          if (data['status'] == 'running') {
            setState(() {
              _isMonitoringBackend = true;
              _monitoringStatusText = 'Status: Monitoring Real-time Data...';
              _statusColor = Colors.lightGreenAccent;
            });
            _connectWebSocket();
          } else {
            setState(() {
              _isMonitoringBackend = false;
              _monitoringStatusText =
                  'Status: Monitoring Stopped. Press Start.';
              _statusColor = Colors.amberAccent;
            });
          }
        }
      } else {
        _showError('Failed to get monitoring status (${response.statusCode})');
      }
    } catch (e) {
      _showError('Error checking status: ${e.toString()}');
    }
  }

  void _connectWebSocket() {
    if (_isWebSocketConnected) return;
    print("Attempting to connect to WebSocket: $_webSocketUrl");

    try {
      _webSocketChannel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));
      _isWebSocketConnected = true;

      if (mounted)
        setState(() {
          _monitoringStatusText = 'Status: Connecting to real-time stream...';
          _statusColor = Colors.lightBlueAccent;
        });

      _webSocketSubscription = _webSocketChannel?.stream.listen(
        (data) {
          if (!mounted) return;
          final Map<String, dynamic> jsonData = json.decode(data as String);

          // Vérifier si le message est un message d'erreur du backend
          if (jsonData.containsKey('error')) {
            _showError("Backend error: ${jsonData['error']}");
            return;
          }

          _updateLatestReadingsAndCharts(jsonData);
        },
        onError: (error) {
          print('WebSocket error: $error');
          if (mounted)
            setState(() {
              _isWebSocketConnected = false;
              _monitoringStatusText = 'Error: Disconnected (error).';
              _statusColor = Colors.redAccent;
            });
          _webSocketChannel = null;
        },
        onDone: () {
          print('WebSocket closed by server.');
          if (mounted)
            setState(() {
              _isWebSocketConnected = false;
              _monitoringStatusText = 'Status: Stream closed.';
              _statusColor = Colors.orangeAccent;
            });
          _webSocketChannel = null;
        },
        cancelOnError: true,
      );
    } catch (e) {
      _showError("Error establishing WebSocket connection: $e");
    }
  }

  void _disconnectWebSocket() {
    _webSocketSubscription?.cancel();
    _webSocketChannel?.sink.close();
    _webSocketChannel = null;
    _isWebSocketConnected = false;
  }

  void _updateLatestReadingsAndCharts(Map<String, dynamic> newDataPoint) {
    if (!mounted) return;
    setState(() {
      _latestReadingsForDisplay.insert(0, newDataPoint);
      if (_latestReadingsForDisplay.length > _maxTextReadingsToShow) {
        _latestReadingsForDisplay.removeLast();
      }

      double xValue =
          _temperatureData.isEmpty ? 0 : _temperatureData.last.x + 1;

      final temp = (newDataPoint['Temp'] as num?)?.toDouble();
      if (temp != null) _temperatureData.add(FlSpot(xValue, temp));

      final humidity = (newDataPoint['Humidity'] as num?)?.toDouble();
      if (humidity != null) _humidityData.add(FlSpot(xValue, humidity));

      final co2 = (newDataPoint['CO2'] as num?)?.toDouble();
      if (co2 != null) _co2Data.add(FlSpot(xValue, co2));

      if (_temperatureData.length > _maxDataPointsOnChart)
        _temperatureData.removeAt(0);
      if (_humidityData.length > _maxDataPointsOnChart)
        _humidityData.removeAt(0);
      if (_co2Data.length > _maxDataPointsOnChart) _co2Data.removeAt(0);

      final lastStatus = newDataPoint['Status'] ?? 'N/A';
      _monitoringStatusText = 'Status: Monitoring ($lastStatus)';
      _statusColor = lastStatus == 'Normal'
          ? Colors.lightGreenAccent
          : Colors.orangeAccent;
    });
  }

  Future<void> _startMonitoring() async {
    setState(() {
      _monitoringStatusText = 'Status: Starting monitoring...';
      _statusColor = Colors.lightBlueAccent;
    });
    try {
      final response =
          await http.post(Uri.parse('$_apiBaseUrl/monitoring/start'));
      if (response.statusCode == 200) {
        if (mounted)
          setState(() {
            _isMonitoringBackend = true;
            _monitoringStatusText = 'Status: Monitoring Real-time Data...';
            _statusColor = Colors.lightGreenAccent;
          });
        _connectWebSocket();
      } else {
        _showError('Failed to start monitoring (${response.statusCode})');
      }
    } catch (e) {
      _showError('Error starting monitoring: ${e.toString()}');
    }
  }

  Future<void> _stopMonitoring() async {
    _disconnectWebSocket();
    setState(() {
      _monitoringStatusText = 'Status: Stopping monitoring...';
      _statusColor = Colors.orangeAccent;
    });
    try {
      final response =
          await http.post(Uri.parse('$_apiBaseUrl/monitoring/stop'));
      if (response.statusCode == 200) {
        if (mounted)
          setState(() {
            _isMonitoringBackend = false;
            _monitoringStatusText = 'Status: Monitoring Stopped. Press Start.';
            _statusColor = Colors.amberAccent;
            _temperatureData.clear();
            _humidityData.clear();
            _co2Data.clear();
          });
      } else {
        _showError('Failed to stop monitoring (${response.statusCode})');
      }
    } catch (e) {
      _showError('Error stopping monitoring: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
    if (mounted)
      setState(() {
        _monitoringStatusText = 'Error: Check connection';
        _statusColor = Colors.redAccent;
      });
  }

  // --- build() METHOD CORRIGÉ ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.2),
        elevation: 0,
        title: Text('Real-time Environment',
            style: GoogleFonts.pacifico(color: Colors.white, fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.white, size: 28),
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const FarmerDashboard())),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset('assets/chiken4.jpg', fit: BoxFit.cover)),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            // ✨ MODIFICATION CLÉ : SingleChildScrollView enveloppe maintenant la Column principale
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  // La Column n'est plus dans un Expanded, elle prend la taille de son contenu
                  children: [
                    // --- Controls and Status Section ---
                    _buildControlsSection(),
                    const Divider(color: Colors.white30, height: 30),

                    // --- Latest Readings Section ---
                    _buildLatestReadingsSection(),
                    const Divider(color: Colors.white30, height: 30),

                    // --- Charts Section ---
                    // Plus besoin de Expanded ou de SingleChildScrollView ici
                    _buildChart(_temperatureData, Colors.orangeAccent,
                        "Temperature (°C)", 15, 40),
                    const SizedBox(height: 24),
                    _buildChart(_humidityData, Colors.cyanAccent,
                        "Humidity (%)", 30, 90),
                    const SizedBox(height: 24),
                    _buildChart(_co2Data, Colors.lightGreenAccent, "CO2 (ppm)",
                        0, 3000),
                    const SizedBox(height: 24),

                    // --- Navigation to Historical Charts ---
                    TextButton.icon(
                      icon: const Icon(Icons.show_chart, color: Colors.white70),
                      label: const Text('View Detailed Historical Charts',
                          style: TextStyle(color: Colors.white70)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EnvChartsPage(
                              initialTemperatureData: _temperatureData,
                              initialHumidityData: _humidityData,
                              initialCo2Data: _co2Data,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  // Aucune modification n'est nécessaire dans les helpers
  Widget _buildControlsSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/chiken12.png', height: 100),
        const SizedBox(height: 10),
        const Text(
          'Live farm monitoring and health predictions.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Start'),
              onPressed: _isMonitoringBackend ? null : _startMonitoring,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _isMonitoringBackend
                      ? Colors.grey.withOpacity(0.4)
                      : Colors.green.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Stop'),
              onPressed: !_isMonitoringBackend ? null : _stopMonitoring,
              style: ElevatedButton.styleFrom(
                  backgroundColor: !_isMonitoringBackend
                      ? Colors.grey.withOpacity(0.4)
                      : Colors.red.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          _monitoringStatusText,
          style: TextStyle(
              color: _statusColor, fontSize: 15, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildChart(List<FlSpot> data, Color lineColor, String title,
      double minY, double maxY) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        AspectRatio(
          aspectRatio: 2.0,
          child: data.isEmpty
              ? Center(
                  child: Text("Waiting for data for $title...",
                      style: const TextStyle(color: Colors.white54)))
              : LineChart(
                  LineChartData(
                    backgroundColor: Colors.transparent,
                    lineTouchData: const LineTouchData(enabled: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: (maxY - minY) / 4,
                      getDrawingHorizontalLine: (value) =>
                          const FlLine(color: Colors.white24, strokeWidth: 0.5),
                      getDrawingVerticalLine: (value) =>
                          const FlLine(color: Colors.white24, strokeWidth: 0.5),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 10)),
                          interval: (maxY - minY) / 4,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.white30, width: 1)),
                    minX: data.isNotEmpty ? data.first.x : 0,
                    maxX: data.isNotEmpty
                        ? data.last.x
                        : _maxDataPointsOnChart.toDouble() - 1,
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: data,
                        isCurved: true,
                        color: lineColor,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                            show: true, color: lineColor.withOpacity(0.2)),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildLatestReadingsSection() {
    if (_latestReadingsForDisplay.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Text('Waiting for latest readings...',
            style:
                TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
      );
    }
    final latest = _latestReadingsForDisplay.first;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Latest Reading (${latest['datetime_str'] ?? 'N/A'}):",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 8),
          _buildReadingItem('Temperature',
              '${(latest['Temp'] as num?)?.toStringAsFixed(1) ?? 'N/A'}°C'),
          _buildReadingItem('Humidity',
              '${(latest['Humidity'] as num?)?.toStringAsFixed(1) ?? 'N/A'}%'),
          _buildReadingItem('CO2',
              '${(latest['CO2'] as num?)?.toStringAsFixed(1) ?? 'N/A'} ppm'),
          _buildReadingItem('Status', latest['Status'] ?? 'N/A',
              color: latest['Status'] == 'Abnormal'
                  ? Colors.orangeAccent.shade200
                  : Colors.greenAccent.shade400),
          _buildReadingItem('Normal Prob.',
              '${(latest['Proba_Normal_pct'] as num?)?.toStringAsFixed(1) ?? 'N/A'}%'),
          _buildReadingItem('Abnormal Prob.',
              '${(latest['Proba_Abnormal_pct'] as num?)?.toStringAsFixed(1) ?? 'N/A'}%'),
        ],
      ),
    );
  }

  Widget _buildReadingItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
