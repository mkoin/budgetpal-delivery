import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:markets_deliveryboy/src/models/payout.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Order>> getOrders() async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> _queryParams = {};
  final String orderStatusId = "5"; // for delivered status
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['with'] =
      'driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress;payment';
  _queryParams['search'] =
      'driver.id:${_user.id};order_status_id:$orderStatusId;delivery_address_id:null';
  _queryParams['searchFields'] =
      'driver.id:=;order_status_id:<>;delivery_address_id:<>';
  _queryParams['searchJoin'] = 'and';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'asc';
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getAllOrders() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var lat = prefs.getString('latitude');
  var long = prefs.getString('longitude');
  Uri uri = Helper.getUri('api/driver/allOrders');
  Map<String, dynamic> _queryParams = {};
  final String orderStatusId = "5"; // for delivered status
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['latitude'] = lat;
  _queryParams['longitude'] = long;
  _queryParams['with'] =
      'driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress;payment';
  // _queryParams['search'] = 'driver.id:${_user.id};order_status_id:$orderStatusId;delivery_address_id:null';
  _queryParams['searchFields'] =
      'driver.id:=;order_status_id:<>;delivery_address_id:<>';
  _queryParams['searchJoin'] = 'and';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'asc';
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getNearOrders(
    Address myAddress, Address areaAddress) async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['limit'] = '6';
  _queryParams['with'] =
      'driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress;payment';
  _queryParams['search'] = 'driver.id:${_user.id};delivery_address_id:null';
  _queryParams['searchFields'] = 'driver.id:=;delivery_address_id:<>';
  _queryParams['searchJoin'] = 'and';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders?${_apiToken}with=driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress&search=driver.id:${_user.id};order_status_id:$orderStatusId&searchFields=driver.id:=;order_status_id:=&searchJoin=and&orderBy=id&sortedBy=desc';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getOrdersHistory() async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> _queryParams = {};
  final String orderStatusId = "5"; // for delivered status
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['with'] =
      'driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress;payment';
  _queryParams['search'] =
      'driver.id:${_user.id};order_status_id:$orderStatusId;delivery_address_id:null';
  _queryParams['searchFields'] =
      'driver.id:=;order_status_id:=;delivery_address_id:<>';
  _queryParams['searchJoin'] = 'and';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders?${_apiToken}with=driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress&search=driver.id:${_user.id};order_status_id:$orderStatusId&searchFields=driver.id:=;order_status_id:=&searchJoin=and&orderBy=id&sortedBy=desc';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getOrder(orderId) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(new Order());
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}orders/$orderId?${_apiToken}with=user;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress;payment';
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getObjectData(data))
      .map((data) {
    return Order.fromJSON(data);
  });
}

Future<Stream<Order>> getRecentOrders() async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['limit'] = '4';
  _queryParams['with'] =
      'driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress;payment';
  _queryParams['search'] = 'driver.id:${_user.id};delivery_address_id:null';
  _queryParams['searchFields'] = 'driver.id:=;delivery_address_id:<>';
  _queryParams['searchJoin'] = 'and';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders?${_apiToken}with=driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress&search=driver.id:${_user.id};order_status_id:$orderStatusId&searchFields=driver.id:=;order_status_id:=&searchJoin=and&orderBy=id&sortedBy=desc';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Payout>> getDriversPayouts() async {
  Uri uri = Uri.parse(
      '${GlobalConfiguration().getString('api_base_url')}driversPayouts');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;
  _queryParams['api_token'] = _user.apiToken;
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Payout.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Payout.fromJSON({}));
  }
}

Future<Stream<OrderStatus>> getOrderStatus() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(new OrderStatus());
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}order_statuses?$_apiToken';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return OrderStatus.fromJSON(data);
  });
}

Future<Map> deliveredOrder(Order order, String code, String spendAmount) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    // return new Order();
    var res = {"message": "Unable to deliver Order", "status": false};
    return res;
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}deliverUpdate/${order.id}?$_apiToken';
  final client = new http.Client();
  var updateOrder = {
    "order": order.deliveredMap(),
    "code": code,
    "spendAmount": spendAmount
  };
  final response = await client.put(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(updateOrder),
  );
  print("HELLO ${response.body}");
  var res = {
    "message": "${json.decode(response.body)['message']}",
    "status": json.decode(response.body)['success']
  };
  return res;

  // return Order.fromJSON(json.decode(response.body)['data']);
}

Future<Map> cancelledOrder(Order order) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    // return new Order();
    var res = {"message": "Unable to deliver Order", "status": false};
    return res;
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}cancelOrder/${order.id}?$_apiToken';
  final client = new http.Client();

  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(order.cancelledMap()),
  );
  print("HELLO ${response.body}");
  var res = {
    "message": "${json.decode(response.body)['message']}",
    "status": json.decode(response.body)['success']
  };
  return res;

  // return Order.fromJSON(json.decode(response.body)['data']);
}

Future<Map> cashOut(String amount, String method, String pin) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    // return new Order();
    var res = {"message": "Unable to Cash out", "status": false};
    return res;
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}driversPayouts?$_apiToken';
  final client = new http.Client();
  var data = {
    "note": "Withdrawal",
    "amount": amount,
    "method": method,
    "pin": pin,
    "user_id": _user.id
  };
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(data),
  );
  print("cashOut ${response.body}");
  var res = {
    "message": "${json.decode(response.body)['message']}",
    "status": json.decode(response.body)['success']
  };
  return res;
}

Future<Map> pickOrder(Order order) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    var res = {"status": false, "message": "Unable to pick Order"};
    return res;
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}pickOrder/${order.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(order.toMap()),
  );
  var res = {
    "status": json.decode(response.body)['success'],
    "message": json.decode(response.body)['message']
  };
  return res;
  // return json.decode(response.body)['message'];
}

Future<bool> assignMarket(Order order, String market_id) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return false;
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}orderMarketSelection/${order.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({"market_id": market_id}),
  );

  print("DATA ${json.decode(response.body)}");
  return json.decode(response.body)['success'];
}
