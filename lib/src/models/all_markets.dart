import '../models/media.dart';

class AllMarket {
  String id;
  String name;

  AllMarket();

  AllMarket.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
    } catch (e) {
      id = '';
      name = '';

      print(e);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
