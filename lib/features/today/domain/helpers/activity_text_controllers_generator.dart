import 'package:flutter/material.dart';

abstract class ActivityTextControllersContainer{
  TextEditingController get nameController;
  TextEditingController get minutesDurationController;
  TextEditingController get workController;
  bool get isEmpty;
}

abstract class ActivityTextControllersGenerator extends ActivityTextControllersContainer{
  void generate();
  void updateNameController(String newValue);
  void updateMinutesDurationController(String newValue);
  updateWorkController(String newValue);
}

class ActivityTextControllersGeneratorImpl implements ActivityTextControllersGenerator{
  static const _nameIndex = 0;
  static const _minutesDurationIndex = 1;
  static const _workIndex = 2;
  late List<TextEditingController> _controllers;
  ActivityTextControllersGeneratorImpl(){
    _controllers = [];
  }
  @override
  void generate() {
    _controllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController()
    ];
  }

  @override
  TextEditingController get nameController =>
    _controllers[_nameIndex];

  @override
  TextEditingController get minutesDurationController =>
    _controllers[_minutesDurationIndex];

  @override
  TextEditingController get workController =>
    _controllers[_workIndex];

  @override
  bool get isEmpty =>
    _controllers.isEmpty;
  
  @override
  void updateNameController(String newValue) {
    _controllers[_nameIndex].text = newValue;
  }

  @override
  void updateMinutesDurationController(String newValue) {
    _controllers[_minutesDurationIndex].text = newValue;
  }

  @override
  updateWorkController(String newValue) {
    _controllers[_workIndex].text = newValue;
  }
}