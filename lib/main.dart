import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const FileComparisonApp());
}

class FileComparisonApp extends StatelessWidget {
  const FileComparisonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Comparison',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FileComparisonScreen(),
    );
  }
}

class FileComparisonScreen extends StatefulWidget {
  const FileComparisonScreen({super.key});

  @override
  _FileComparisonScreenState createState() => _FileComparisonScreenState();
}

class _FileComparisonScreenState extends State<FileComparisonScreen> {
  String? file1Content;
  String? file2Content;
  List<ComparisonResult> comparisonResults = [];
  String? updatedFile1Content;

  Future<void> pickFile1() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          file1Content = String.fromCharCodes(result.files.first.bytes!);
          updatedFile1Content = file1Content; // Initialize with the original content
          print('File 1 Content: $file1Content');
        });
      } else {
        print('File 1 selection canceled');
      }
    } catch (e) {
      print('Error picking File 1: $e');
    }
  }

  Future<void> pickFile2() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          file2Content = String.fromCharCodes(result.files.first.bytes!);
          print('File 2 Content: $file2Content');
        });
      } else {
        print('File 2 selection canceled');
      }
    } catch (e) {
      print('Error picking File 2: $e');
    }
  }

  Future<void> compareFiles() async {
    if (file1Content != null && file2Content != null) {
      final differences = compare(file1Content!, file2Content!);
      setState(() {
        comparisonResults = differences;
        print('Comparison Results: $comparisonResults');
      });
    } else {
      print('One or both files are empty');
    }
  }

  List<ComparisonResult> compare(String content1, String content2) {
    final lines1 = content1.split('\n');
    final lines2 = content2.split('\n');

    List<ComparisonResult> differences = [];
    int maxLength =
        lines1.length > lines2.length ? lines1.length : lines2.length;

    for (int i = 0; i < maxLength; i++) {
      final line1 = i < lines1.length ? lines1[i] : '';
      final line2 = i < lines2.length ? lines2[i] : '';

      if (line1 != line2) {
        differences.add(
          ComparisonResult(
            lineNumber: i + 1,
            file1Line: line1,
            file2Line: line2,
            action: ActionType.none,
          ),
        );
      }
    }

    return differences;
  }

  void applyChange(int index) {
    setState(() {
      comparisonResults[index].action = ActionType.apply;

      // Update file 1 content with the change from file 2
      final result = comparisonResults[index];
      final lines = updatedFile1Content!.split('\n');

      if (result.lineNumber - 1 < lines.length) {
        lines[result.lineNumber - 1] = result.file2Line;
      } else {
        lines.add(result.file2Line);
      }

      updatedFile1Content = lines.join('\n');
      print('Updated File 1 Content: $updatedFile1Content');
    });
  }

  void ignoreChange(int index) {
    setState(() {
      comparisonResults[index].action = ActionType.ignore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Comparison')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickFile1,
              child: Text(
                file1Content == null ? 'Pick First File' : 'File 1 Selected',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickFile2,
              child: Text(
                file2Content == null ? 'Pick Second File' : 'File 2 Selected',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: compareFiles,
              child: const Text('Compare Files'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: comparisonResults.length,
                itemBuilder: (context, index) {
                  final result = comparisonResults[index];
                  return Card(
                    color: result.action == ActionType.none
                        ? Colors.white
                        : result.action == ActionType.apply
                            ? Colors.greenAccent
                            : Colors.redAccent,
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Line ${result.lineNumber}:'),
                          Text('File 1: ${result.file1Line}'),
                          Text('File 2: ${result.file2Line}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => applyChange(index),
                            child: const Text('Apply Change'),
                          ),
                          TextButton(
                            onPressed: () => ignoreChange(index),
                            child: const Text('Ignore Change'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Updated File 1 Content:'),
            Expanded(
              child: SingleChildScrollView(
                child: Text(updatedFile1Content ?? ''),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ComparisonResult {
  final int lineNumber;
  final String file1Line;
  final String file2Line;
  ActionType action;

  ComparisonResult({
    required this.lineNumber,
    required this.file1Line,
    required this.file2Line,
    this.action = ActionType.none,
  });
}

enum ActionType {
  none,
  apply,
  ignore,
}
