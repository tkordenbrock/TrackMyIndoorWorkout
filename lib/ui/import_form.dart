import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import '../import/csv_importer.dart';

typedef void SetProgress(double progress);

class ImportForm extends StatefulWidget {
  @override
  _ImportFormState createState() => _ImportFormState();
}

class _ImportFormState extends State<ImportForm> {
  final dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _filePath;
  DateTime? _activityDateTime;
  bool _isLoading = false;
  double _progressValue = 0.0;
  double _sizeDefault = 10.0;
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sizeDefault = Get.textTheme.headline2!.fontSize!;
  }

  void setProgress(double progress) {
    setState(() {
      _progressValue = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MPower Workout Import'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        progressIndicator: SizedBox(
          child: CircularProgressIndicator(
            strokeWidth: _sizeDefault,
            value: _progressValue,
          ),
          height: _sizeDefault * 2,
          width: _sizeDefault * 2,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'MPower CSV File URL',
                  hintText: 'Paste the CSV file URL',
                  suffixIcon: ElevatedButton(
                    child: Text(
                      '⋯',
                      style: TextStyle(fontSize: 30),
                    ),
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles();
                      if (result != null && result.files.single.path != null) {
                        _textController.text = result.files.single.path!;
                        setState(() {
                          _filePath = result.files.single.path!;
                        });
                      }
                    },
                  ),
                ),
                controller: _textController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please pick a file';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {
                  _filePath = value;
                }),
              ),
              SizedBox(height: 24),
              DateTimeField(
                format: dateTimeFormat,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.access_time),
                  labelText: 'Workout Date & Time',
                  hintText: 'Pick date & time',
                ),
                onShowPicker: (context, currentValue) async {
                  final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                    );
                    return DateTimeField.combine(date, time);
                  } else {
                    return currentValue;
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please pick a date and time';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {
                  _activityDateTime = value;
                }),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState == null) {
                          return;
                        }

                        if (_filePath == null) {
                          Get.snackbar("Error", "Please pick a file");
                        }

                        if (_activityDateTime == null) {
                          Get.snackbar("Error", "Please pick a date and time");
                        }

                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            File file = File(_filePath!);
                            String contents = await file.readAsString();
                            final importer = CSVImporter(start: _activityDateTime);
                            var activity = await importer.import(contents, setProgress);
                            setState(() {
                              _isLoading = false;
                            });
                            if (activity != null) {
                              Get.snackbar("Success", "Workout imported!");
                            } else {
                              Get.snackbar(
                                  "Failure", "Problem while importing: ${importer.message}");
                            }
                          } catch (e, callStack) {
                            setState(() {
                              _isLoading = false;
                            });
                            Get.snackbar("Error", "Import unsuccessful: $e");
                            debugPrintStack(stackTrace: callStack);
                          }
                        } else {
                          Get.snackbar("Error", "Please correct form fields");
                        }
                      },
                      child: Text('Import'),
                    ),
                  ),
                  Expanded(child: Container()),
                  ElevatedButton(
                    child: Text('Reset'),
                    onPressed: () => _formKey.currentState?.reset(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
