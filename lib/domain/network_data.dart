import 'package:commitconf/domain/domain.dart';
import 'package:commitconf/domain/parser.dart';
import 'package:http/http.dart' as http;

const URL =
    'https://raw.githubusercontent.com/jmolins/commitconf/master/data/schedule-data.json';

Future<String> fetchData() async {
  final response = await http.get(URL);
  return response.body;
}

Future<Schedule> getNetworkSchedule() async {
  return parseSchedule(decode(await fetchData()));
}
