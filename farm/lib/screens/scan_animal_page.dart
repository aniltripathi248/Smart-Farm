// ============================================
// SCAN ANIMAL PAGE - AI Animal Health Scanner
// ============================================
// This screen uses TensorFlow Lite to scan animal images
// for health issues. Users can:
// - Take photo with camera
// - Upload photo from gallery
// - Get AI predictions about animal health
// 
// Uses TensorFlow Lite model for image classification.
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

/// ScanAnimalPage - Screen for scanning animals with AI
/// 
/// Flow:
/// 1. Screen opens → initState() loads TensorFlow Lite model
/// 2. If isFromCamera=true, automatically opens camera
/// 3. User takes/selects image
/// 4. Image is processed by TensorFlow Lite model
/// 5. Model returns prediction and confidence score
/// 6. Results displayed to user
/// 
/// Navigation:
/// - Back button → Previous screen (usually DashboardPage)
/// 
/// Accessed from:
/// - DashboardPage "Scan animal" quick action
/// - DashboardPage "Upload file" quick action
class ScanAnimalPage extends StatefulWidget {
  static const routeName = '/scan-animal';
  
  /// Whether to open camera immediately (true) or show upload option (false)
  final bool isFromCamera;

  const ScanAnimalPage({super.key, this.isFromCamera = false});

  @override
  State<ScanAnimalPage> createState() => _ScanAnimalPageState();
}

/// State class for ScanAnimalPage
/// Manages image selection, model loading, and prediction
class _ScanAnimalPageState extends State<ScanAnimalPage> {
  // ============================================
  // STATE VARIABLES
  // ============================================
  // Selected image file (from camera or gallery)
  File? _image;
  
  // Shows loading spinner while processing
  bool _isLoading = false;
  
  // AI model prediction result (e.g., "Healthy", "Disease detected")
  String? _prediction;
  
  // Confidence score (0.0 to 1.0) of the prediction
  double? _confidence;
  
  // Image picker for camera/gallery access
  final ImagePicker _picker = ImagePicker();

  /// Called when screen is first created
  /// 
  /// Flow:
  /// 1. Loads TensorFlow Lite model
  /// 2. If isFromCamera=true, automatically opens camera
  @override
  void initState() {
    super.initState();
    // Load AI model for image classification
    _loadModel();
    // If opened from camera action, immediately open camera
    if (widget.isFromCamera) {
      _pickImageFromCamera();
    }
  }

  /// Loads the TensorFlow Lite model for animal health scanning
  /// 
  /// Flow:
  /// 1. Loads model file from assets
  /// 2. Loads labels file (class names)
  /// 3. Model is ready for image classification
  /// 
  /// Called by: initState()
  /// 
  /// Model files:
  /// - model_unquant.tflite: TensorFlow Lite model
  /// - labels.txt: Class labels (disease names, etc.)
  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading model: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
        _classifyImage(_image!);
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
        _classifyImage(_image!);
      } 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _classifyImage(File image) async {
    setState(() {
      _isLoading = true;
      _prediction = null;
      _confidence = null;
    });

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        setState(() {
          _prediction = recognitions[0]['label'];
          _confidence = recognitions[0]['confidence'];
        });
      } else {
        setState(() {
          _prediction = 'Unable to classify';
          _confidence = 0.0;
        });
      }
    } catch (e) {
      setState(() {
        _prediction = 'Error during classification: $e';
        _confidence = 0.0;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2F2F2F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan Animal',
          style: TextStyle(
            color: Color(0xFF2F2F2F),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_image == null)
                _buildEmptyState()
              else
                _buildImagePreview(),
              const SizedBox(height: 24),
              if (_image == null) _buildActionButtons(),
              if (_isLoading) _buildLoadingIndicator(),
              if (_prediction != null && !_isLoading) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F4),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No image selected',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo or upload from gallery',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.file(
          _image!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickImageFromCamera,
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: const Text(
              'Take Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F7D32),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickImageFromGallery,
            icon: const Icon(Icons.upload_file, color: Color(0xFF2F7D32)),
            label: const Text(
              'Upload File',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F7D32),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2F7D32), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F7D32)),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing image...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrediction(String? prediction) {
    if (prediction == null) return 'Unknown';
    
    // Remove leading number and space (e.g., "0 " or "1 ")
    String formatted = prediction.replaceFirst(RegExp(r'^\d+\s+'), '');
    
    // Clean up specific cases
    if (formatted.toLowerCase().contains('ring worm disease found condition')) {
      formatted = 'Ring Worm Disease Found';
    } else if (formatted.toLowerCase().contains('normal condition')) {
      formatted = 'Normal Condition';
    }
    
    return formatted;
  }

  Widget _buildResultCard() {
    final formattedPrediction = _formatPrediction(_prediction);
    final isNormal = formattedPrediction.toLowerCase().contains('normal');
    final isDisease = formattedPrediction.toLowerCase().contains('ring worm');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isNormal
                    ? Icons.check_circle
                    : isDisease
                        ? Icons.warning
                        : Icons.info,
                color: isNormal
                    ? Colors.green
                    : isDisease
                        ? Colors.orange
                        : Colors.blue,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Scan Result',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isNormal
                  ? Colors.green.withOpacity(0.1)
                  : isDisease
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedPrediction,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isNormal
                        ? Colors.green[800]
                        : isDisease
                            ? Colors.orange[800]
                            : Colors.blue[800],
                  ),
                ),
                if (_confidence != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Confidence: ${(_confidence! * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _image = null;
                  _prediction = null;
                  _confidence = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F7D32),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text(
                'Scan Another',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
