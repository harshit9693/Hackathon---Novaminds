class Prescription {
  final String id;
  final String fileName;
  final String filePath;
  final DateTime uploadDate;
  final String? doctorName;
  final String? hospitalName;
  final DateTime? prescriptionDate;
  final List<String> medications;
  final String? notes;
  final String? analysisResult;

  Prescription({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.uploadDate,
    this.doctorName,
    this.hospitalName,
    this.prescriptionDate,
    this.medications = const [],
    this.notes,
    this.analysisResult,
  });

  Prescription copyWith({
    String? id,
    String? fileName,
    String? filePath,
    DateTime? uploadDate,
    String? doctorName,
    String? hospitalName,
    DateTime? prescriptionDate,
    List<String>? medications,
    String? notes,
    String? analysisResult,
  }) {
    return Prescription(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      uploadDate: uploadDate ?? this.uploadDate,
      doctorName: doctorName ?? this.doctorName,
      hospitalName: hospitalName ?? this.hospitalName,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
      medications: medications ?? this.medications,
      notes: notes ?? this.notes,
      analysisResult: analysisResult ?? this.analysisResult,
    );
  }
}