import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UploadCSVPage extends StatefulWidget {
  const UploadCSVPage({super.key});

  @override
  State<UploadCSVPage> createState() => _UploadCSVPageState();
}

class _UploadCSVPageState extends State<UploadCSVPage> {
  String? _fileName;
  String? _fileContent;
  List<dynamic>? _predictionResults;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  static const String _backendUrl = 'http://192.168.0.193:8080/predict';
  static const int _maxPreviewLines = 50;

  Future<void> _pickCSVFile() async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.first;
      if (pickedFile.bytes == null) {
        throw Exception('File is empty or inaccessible');
      }

      setState(() {
        _fileName = pickedFile.name;
        _predictionResults = null;
      });

      final content = utf8.decode(pickedFile.bytes!);
      setState(() => _fileContent = _limitPreviewContent(content));

      await _sendCSVToAPI(pickedFile.bytes!, pickedFile.name);
    } catch (e) {
      _handleError('Error selecting the file: ${e.toString()}');
    }
  }

  String _limitPreviewContent(String content) {
    final lines = content.split('\n');
    return lines.take(_maxPreviewLines).join('\n');
  }

  Future<void> _sendCSVToAPI(Uint8List fileBytes, String filename) async {
    setState(() => _isLoading = true);
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_backendUrl));
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: filename,
          contentType: MediaType('text', 'csv'),
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw Exception('Server error (${response.statusCode}): $responseData');
      }

      final result = jsonDecode(responseData);
      if (result is! List) {
        throw Exception('Invalid server response format');
      }

      setState(() {
        _predictionResults = result;
        _isLoading = false;
      });
      _showPredictionResults(result);
    } catch (e) {
      _handleError('Connection error: ${e.toString()}');
    }
  }

  void _showPredictionResults(List<dynamic> results) {
    if (results.isEmpty) {
      _handleError('No prediction results returned');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Prediction Results",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite, // Permet au dialogue de s'étendre
          height: MediaQuery.of(context).size.height *
              0.7, // Limite la hauteur du dialogue à 70% de l'écran
          child: SingleChildScrollView(
            // Scroll vertical pour le contenu du dialogue
            child: SingleChildScrollView(
              // Scroll horizontal pour la DataTable
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('Age')),
                  DataColumn(label: Text('Temperature')),
                  DataColumn(label: Text('Humidity')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Abnormal')),
                  DataColumn(label: Text('Normal')),
                ],
                rows: results.map<DataRow>((item) {
                  // Affichera toutes les lignes
                  final isNormal = item['Status'] == 'Normal';
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                      (states) => isNormal
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                    ),
                    cells: [
                      DataCell(Text(item['Age']?.toString() ?? 'N/A')),
                      DataCell(Text(
                          (item['Temp'] as num?)?.toStringAsFixed(1) ?? 'N/A')),
                      DataCell(Text(item['Humidity']?.toString() ?? 'N/A')),
                      DataCell(Text(
                        item['Status']?.toString() ?? 'N/A',
                        style: TextStyle(
                          color: isNormal
                              ? Colors.green.shade700
                              : Colors.red.shade700, // Couleurs plus vives
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      DataCell(Text(
                          '${item['Proba_Abnormal (%)']?.toString() ?? 'N/A'}%',
                          style: TextStyle(
                              color:
                                  Colors.red.shade700))), // Couleur plus vive
                      DataCell(Text(
                          '${item['Proba_Normal (%)']?.toString() ?? 'N/A'}%',
                          style: TextStyle(
                              color:
                                  Colors.green.shade700))), // Couleur plus vive
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: _exportResults,
            child: const Text('Export CSV'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportResults() async {
    if (_predictionResults == null || _predictionResults!.isEmpty) return;

    try {
      final headers = _predictionResults!.first.keys.toList();
      final rows = _predictionResults!.map((row) {
        return headers.map((h) => row[h]?.toString() ?? '').join(",");
      }).join("\n");
      final csv = '${headers.join(",")}\n$rows';
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download",
            "predictions_${DateTime.now().millisecondsSinceEpoch}.csv")
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      _handleError('Failed to export results: ${e.toString()}');
    }
  }

  void _handleError(String message) {
    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
          'Poultry Analysis',
          style: GoogleFonts.pacifico(
            color: Colors.white,
            fontSize: 22,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/chiken6.png', width: 150, height: 150),
                    const SizedBox(height: 20),
                    Text(
                      'Upload a CSV file containing your farm\'s environmental data '
                      'for AI-based prediction of poultry health risk.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickCSVFile,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(
                        _isLoading ? 'Analyzing...' : 'Upload CSV',
                        style: const TextStyle(fontSize: 16),
                      ),
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
                    ),
                    const SizedBox(height: 30),
                    if (_hasError)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage ?? 'An error occurred',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_fileName != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.insert_drive_file,
                                    color: Colors.white70),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _fileName!,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (_fileContent != null) ...[
                              const SizedBox(height: 10),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 150,
                                ),
                                child: SingleChildScrollView(
                                  child: Text(
                                    _fileContent!,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
