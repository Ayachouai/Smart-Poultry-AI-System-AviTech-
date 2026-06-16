import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class EnvDataPage extends StatefulWidget {
  const EnvDataPage({super.key});

  @override
  State<EnvDataPage> createState() => _EnvDataPageState();
}

class _EnvDataPageState extends State<EnvDataPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _co2Controller =
      TextEditingController(text: '800');
  final TextEditingController _measuredTempController =
      TextEditingController(text: '24');
  final TextEditingController _humidityController =
      TextEditingController(text: '60');
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _requiredTempController = TextEditingController();
  final TextEditingController _ventLevelController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _feedController = TextEditingController();
  final TextEditingController _fanCountController = TextEditingController();

  String? _result;
  bool isLoading = false;

  void _getResult() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final uri = Uri.parse('http://192.168.0.193:8080/predict_single');
        final response = await http.post(
          uri,
          body: {
            'age': _ageController.text,
            'co2': _co2Controller.text,
            'req_temp': _requiredTempController.text,
            'temp': _measuredTempController.text,
            'humidity': _humidityController.text,
            'vent_level': _ventLevelController.text,
            'daily_water': _waterController.text,
            'feed': _feedController.text,
            'fan_nums': _fanCountController.text,
          },
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          setState(() {
            _result =
                "🐔 Status: ${result['Status']}\n🔴 Abnormal: ${result['Proba_Abnormal (%)']}%\n🟢 Normal: ${result['Proba_Normal (%)']}%";
          });
        } else {
          setState(() => _result = "❌ Server error: ${response.statusCode}");
        }
      } catch (e) {
        setState(() => _result = "❌ Connection error: $e");
      }

      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _co2Controller.dispose();
    _measuredTempController.dispose();
    _humidityController.dispose();
    _ageController.dispose();
    _requiredTempController.dispose();
    _ventLevelController.dispose();
    _waterController.dispose();
    _feedController.dispose();
    _fanCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.2),
        elevation: 0,
        title: Text(
          'Enter Environmental Data',
          style: GoogleFonts.pacifico(color: Colors.white, fontSize: 22),
        ),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/chiken4.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/chiken7.png',
                        height: 150, fit: BoxFit.contain),
                    const SizedBox(height: 15),
                    Text(
                      'Please fill all the fields with appropriate data to predict poultry health.',
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildInputField(
                              label: 'Age (days)',
                              controller: _ageController,
                              hint: 'e.g. 21'),
                          _buildInputField(
                              label: 'Required Temp (°C)',
                              controller: _requiredTempController,
                              hint: 'e.g. 25'),
                          _buildInputField(
                              label: 'Measured Temp (°C)',
                              controller: _measuredTempController,
                              hint: 'e.g. 24'),
                          _buildInputField(
                              label: 'Humidity (%)',
                              controller: _humidityController,
                              hint: 'e.g. 60'),
                          _buildInputField(
                              label: 'CO₂ (ppm)',
                              controller: _co2Controller,
                              hint: 'e.g. 800'),
                          _buildInputField(
                              label: 'Ventilation Level (%)',
                              controller: _ventLevelController,
                              hint: 'e.g. 50'),
                          _buildInputField(
                              label: 'No. of Fans',
                              controller: _fanCountController,
                              hint: 'e.g. 4'),
                          _buildInputField(
                              label: 'Water (L/day)',
                              controller: _waterController,
                              hint: 'e.g. 150.5'),
                          _buildInputField(
                              label: 'Feed (kg/day)',
                              controller: _feedController,
                              hint: 'e.g. 120.75'),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: isLoading ? null : _getResult,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 35,
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2)
                                : const Text('Get Result',
                                    style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(height: 30),
                          if (_result != null)
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.white54),
                              ),
                              child: Text(
                                _result!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType =
        const TextInputType.numberWithOptions(decimal: true),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (keyboardType == TextInputType.number ||
              keyboardType ==
                  const TextInputType.numberWithOptions(decimal: true)) {
            if (double.tryParse(value) == null) {
              return 'Enter a valid number';
            }
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
