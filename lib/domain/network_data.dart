import 'package:commitconf/domain/domain.dart';
import 'package:commitconf/domain/parser.dart';
import 'package:http/http.dart' as http;

const URL =
    'https://raw.githubusercontent.com/jmolins/commitconf-flutter/master/data/schedule-data.json';

Future<String> fetchData() async {
  try {
    final response = await http.get(URL);
    return response.body;
  } catch (error) {
    print("Network Error :-(");
    print(error);
  }
}

Future<Schedule> getNetworkSchedule() async {
  return parseSchedule(decode(await fetchData()));
}
