import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'home.dart';

enum AnalysisType { none, chicken, droppings }

class ChickenHealthPage extends StatefulWidget {
  const ChickenHealthPage({super.key});

  @override
  State<ChickenHealthPage> createState() => _ChickenHealthPageState();
}

class _ChickenHealthPageState extends State<ChickenHealthPage> {
  XFile? _selectedImage;
  AnalysisType _currentAnalysisType = AnalysisType.none;
  final ImagePicker _picker = ImagePicker();
  String? _analysisResultText;
  bool _isAnalyzing = false;

  static const String _baseBackendUrl = 'http://192.168.0.193:8080';
  static const String _chickenAnalysisEndpoint =
      '$_baseBackendUrl/analyze_poultry_image';
  static const String _droppingsAnalysisEndpoint =
      '$_baseBackendUrl/analyze_dropping_image';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image =
          await _picker.pickImage(source: source, imageQuality: 85);
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _analysisResultText = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar(
          "Erreur lors de la sélection de l'image : ${e.toString()}");
    }
  }

  void _resetSelection() {
    setState(() {
      _selectedImage = null;
      _currentAnalysisType = AnalysisType.none;
      _analysisResultText = null;
      _isAnalyzing = false;
    });
  }

  // ✨ FONCTION CORRIGÉE ✨
  Future<void> _analyzeImage() async {
    if (_selectedImage == null || _currentAnalysisType == AnalysisType.none) {
      _showErrorSnackBar("Please select an image and analysis type.");
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResultText = null;
    });

    String endpointUrl;
    const String imageFieldName = 'file';

    if (_currentAnalysisType == AnalysisType.chicken) {
      endpointUrl = _chickenAnalysisEndpoint;
    } else if (_currentAnalysisType == AnalysisType.droppings) {
      endpointUrl = _droppingsAnalysisEndpoint;
    } else {
      _showErrorSnackBar("Type d'analyse invalide.");
      setState(() => _isAnalyzing = false);
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(endpointUrl));

      print("Envoi de la requête vers : $endpointUrl");

      final imageBytes = await _selectedImage!.readAsBytes();
      String fileExtension = _selectedImage!.name.split('.').last.toLowerCase();
      String mimeType =
          (['jpg', 'jpeg'].contains(fileExtension)) ? 'jpeg' : 'png';

      request.files.add(
        http.MultipartFile.fromBytes(
          imageFieldName,
          imageBytes,
          filename: _selectedImage!.name,
          contentType: MediaType('image', mimeType),
        ),
      );
      print(
          "Envoi de l'image '${_selectedImage!.name}' en tant que champ '$imageFieldName'");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Response Status : ${response.statusCode}");
      print("Response body : ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String status = data['status'] as String? ?? 'N/A';

        // ✨ CORRECTION PRINCIPALE : Utiliser la bonne clé JSON ✨
        final dynamic confidenceValue = data['confidence'];

        double confidencePercent = 0.0;
        if (confidenceValue is num) {
          confidencePercent = confidenceValue.toDouble();
        }

        setState(() {
          // Texte mis à jour pour plus de clarté
          _analysisResultText =
              "$status (Confidence: ${confidencePercent.toStringAsFixed(1)}%)";
        });
      } else {
        String detail =
            "Erreur serveur inconnue. Statut : ${response.statusCode}";
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          detail = errorData['detail']?.toString() ?? response.body;
        } catch (e) {
          detail = response.body.isNotEmpty
              ? response.body
              : "Erreur serveur sans détails.";
        }
        _showErrorSnackBar("L'analyse a échoué : $detail");
      }
    } catch (e) {
      print("Exception durant _analyzeImage : $e");
      _showErrorSnackBar(
          "Erreur côté client durant l'analyse : ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildInitialSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/chiken3.png', height: 160),
        const SizedBox(height: 20),
        const Text(
          'What do you want to analyze?',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 25),
        ElevatedButton.icon(
          icon: const Icon(Icons.cruelty_free_outlined),
          label: const Text("Analyze the appearance of the chicken",
              style: TextStyle(fontSize: 15)),
          onPressed: () =>
              setState(() => _currentAnalysisType = AnalysisType.chicken),
          style: _analysisButtonStyle(),
        ),
        const SizedBox(height: 15),
        ElevatedButton.icon(
          icon: const Icon(Icons.biotech_outlined),
          label: const Text('Analyze the droppings',
              style: TextStyle(fontSize: 15)),
          onPressed: () =>
              setState(() => _currentAnalysisType = AnalysisType.droppings),
          style: _analysisButtonStyle(),
        ),
      ],
    );
  }

  Widget _buildImageSelectionAndAnalysis() {
    String typeText =
        _currentAnalysisType == AnalysisType.chicken ? "chicken" : "droppings";
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Upload or take a photo of the $typeText:',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed:
                  _isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.image_outlined),
              label: const Text('Gallery'),
              style: _actionButtonStyle(),
            ),
            ElevatedButton.icon(
              onPressed:
                  _isAnalyzing ? null : () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Camera'),
              style: _actionButtonStyle(),
            ),
          ],
        ),
        const SizedBox(height: 25),
        if (_selectedImage != null)
          Column(
            children: [
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white60, width: 2),
                  image: DecorationImage(
                    image: FileImage(File(_selectedImage!.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isAnalyzing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.analytics_outlined),
                      label: const Text("Analyze the image",
                          style: TextStyle(fontSize: 16)),
                      onPressed: _analyzeImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
            ],
          ),
        if (_analysisResultText != null && !_isAnalyzing)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white30)),
              child: Text(
                _analysisResultText!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        const SizedBox(height: 20),
        TextButton.icon(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: Colors.white70),
          label: const Text("Change analysis type",
              style: TextStyle(color: Colors.white70)),
          onPressed: _isAnalyzing ? null : _resetSelection,
        ),
      ],
    );
  }

  ButtonStyle _analysisButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white.withOpacity(0.25),
      foregroundColor: Colors.white,
      minimumSize: const Size(280, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  ButtonStyle _actionButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white.withOpacity(0.2),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Health Analysis',
          style: GoogleFonts.pacifico(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Colors.white.withOpacity(0.15),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FarmerDashboard()),
            );
          },
        ),
        actions: [
          if (_currentAnalysisType != AnalysisType.none ||
              _selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh_outlined, color: Colors.white),
              onPressed: _isAnalyzing ? null : _resetSelection,
              tooltip: "Start again",
            )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/chiken4.jpg',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.55)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
              child: Center(
                child: SingleChildScrollView(
                  child: _currentAnalysisType == AnalysisType.none
                      ? _buildInitialSelection()
                      : _buildImageSelectionAndAnalysis(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
