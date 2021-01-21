import 'package:global_configuration/global_configuration.dart';

class Payout {
  String id;
  String user_id;
  String method;
  String amount;
  String paid_date;
  String note;
  String created_at;
  String updated_at;

  Payout();

  Payout.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      user_id = jsonMap['user_id'].toString();
      method = jsonMap['method'].toString();
      amount = jsonMap['amount'].toString();
      paid_date = jsonMap['paid_date'].toString();
      note = jsonMap['note'].toString();
      created_at = jsonMap['created_at'].toString();
      updated_at = jsonMap['updated_at'].toString();
    } catch (e) {
      method = "";
      amount = "";
      paid_date = "";
      note = "";
      created_at = "";
      updated_at = "";
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["user_id"] = user_id;
    map["method"] = method;
    map["amount"] = amount;
    map["paid_date"] = paid_date;
    map["note"] = note;
    map['created_at'] = created_at;
    map['updated_at'] = updated_at;
    return map;
  }

  @override
  String toString() {
    return this.toMap().toString();
  }
}
