import 'dart:async' show Future;

import 'package:commitconf/domain/domain.dart';
import 'package:commitconf/domain/parser.dart';
import 'package:flutter/material.dart';

Future<String> loadJson(BuildContext context) async {
  return await DefaultAssetBundle.of(context)
      .loadString('assets/schedule-data.json');
}

Future<Schedule> getSchedule(BuildContext context) async {
  return parseSchedule(decode(await loadJson(context)));
}
