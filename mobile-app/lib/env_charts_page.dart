import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'home.dart';

const String _backendIp = "192.168.0.193";
const String _apiBaseUrl = "http://$_backendIp:8080";

class EnvChartsPage extends StatefulWidget {
  // Accepter les données initiales de la page précédente
  final List<FlSpot> initialTemperatureData;
  final List<FlSpot> initialHumidityData;
  final List<FlSpot> initialCo2Data;

  const EnvChartsPage({
    super.key,
    this.initialTemperatureData = const [],
    this.initialHumidityData = const [],
    this.initialCo2Data = const [],
  });

  @override
  State<EnvChartsPage> createState() => _EnvChartsPageState();
}

class _EnvChartsPageState extends State<EnvChartsPage> {
  String _selectedChart = 'Temperature';
  bool _isLoading = false;
  String? _errorMessage;

  // Stocker toutes les données
  late List<FlSpot> _temperatureData;
  late List<FlSpot> _humidityData;
  late List<FlSpot> _co2Data;

  @override
  void initState() {
    super.initState();
    // Utiliser les données initiales passées en paramètre
    _temperatureData = List.from(widget.initialTemperatureData);
    _humidityData = List.from(widget.initialHumidityData);
    _co2Data = List.from(widget.initialCo2Data);

    // Si aucune donnée initiale n'est fournie, charger l'historique par défaut
    if (_temperatureData.isEmpty) {
      _fetchHistoricalData();
    }
  }

  Future<void> _fetchHistoricalData({int hours = 24}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/monitoring/history?hours=$hours'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> records = jsonDecode(response.body);

        List<FlSpot> tempData = [];
        List<FlSpot> humData = [];
        List<FlSpot> co2Data = [];

        // Utiliser l'index pour l'axe X pour un affichage simple et régulier
        for (var i = 0; i < records.length; i++) {
          final record = records[i];
          final double xValue = i.toDouble();

          if (record['Temp'] != null)
            tempData.add(FlSpot(xValue, (record['Temp'] as num).toDouble()));
          if (record['Humidity'] != null)
            humData.add(FlSpot(xValue, (record['Humidity'] as num).toDouble()));
          if (record['CO2'] != null)
            co2Data.add(FlSpot(xValue, (record['CO2'] as num).toDouble()));
        }

        setState(() {
          _temperatureData = tempData;
          _humidityData = humData;
          _co2Data = co2Data;
        });
      } else {
        throw Exception(
            'Failed to load data (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Historical Data',
            style: GoogleFonts.pacifico(color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : () => _fetchHistoricalData(),
            tooltip: 'Reload last 24h data',
          )
        ],
      ),
      body: Stack(
        children: [
          Image.asset('assets/chiken4.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.center,
                  children: ['Temperature', 'Humidity', 'CO₂']
                      .map((type) => ChoiceChip(
                            label: Text(type,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                            selected: _selectedChart == type,
                            onSelected: (_) =>
                                setState(() => _selectedChart = type),
                            selectedColor: Colors.teal.withOpacity(0.7),
                            backgroundColor: Colors.white.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                    color: Colors.transparent)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white30)),
                      child: _buildChartContainer(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer() {
    if (_isLoading)
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(_errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent)),
        ),
      );
    }

    List<FlSpot> data;
    Color lineColor;
    String unit;

    switch (_selectedChart) {
      case 'CO₂':
        data = _co2Data;
        lineColor = Colors.lightGreenAccent;
        unit = 'ppm';
        break;
      case 'Humidity':
        data = _humidityData;
        lineColor = Colors.cyanAccent;
        unit = '%';
        break;
      case 'Temperature':
      default:
        data = _temperatureData;
        lineColor = Colors.orangeAccent;
        unit = '°C';
        break;
    }

    if (data.isEmpty) {
      return const Center(
          child: Text("No data available for this chart.",
              style: TextStyle(color: Colors.white70)));
    }

    return LineChart(
      LineChartData(
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) =>
              const FlLine(color: Colors.white24, strokeWidth: 0.5),
          getDrawingVerticalLine: (value) =>
              const FlLine(color: Colors.white24, strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 10)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
            show: true, border: Border.all(color: Colors.white30, width: 1)),
        lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots
                      .map((spot) => LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)} $unit',
                          const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)))
                      .toList();
                })),
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            color: lineColor,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData:
                BarAreaData(show: true, color: lineColor.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }
}
