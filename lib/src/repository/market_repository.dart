import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:markets_deliveryboy/src/helpers/custom_trace.dart';
import 'package:markets_deliveryboy/src/models/all_markets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/helper.dart';
import '../models/market.dart';
import '../models/review.dart';

// Future<Stream<Market>> getNearMarkets(
//     LocationData myLocation, LocationData areaLocation) async {
Future<Stream<Market>> getNearMarkets() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var latitude = prefs.getString('latitude');
  var longitude = prefs.getString('longitude');

  print("HAAAAAAAAAAAAAAAAAPA $longitude");
  String _nearParams = '';
  String _orderLimitParam = '';
  // if (myLocation != null && areaLocation != null) {
  //   _orderLimitParam = 'orderBy=area&limit=5';
  //   _nearParams =
  //       '&myLon=${myLocation.longitude}&myLat=${myLocation.latitude}&areaLon=${areaLocation.longitude}&areaLat=${areaLocation.latitude}';
  // }

  _orderLimitParam = 'orderBy=area&limit=10';
  _nearParams = '&myLon=${longitude}&myLat=${latitude}&areaLon=${longitude}&areaLat=${latitude}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}markets?$_nearParams&$_orderLimitParam';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {

    return Market.fromJSON(data);
  });
}

Future<Stream<Market>> getAllMarkets() async {
  Uri uri = Helper.getUri('api/markets');
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Market.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Market.fromJSON({}));
  }
  // final client = new http.Client();
  // final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  // print("HERE FICE ");
  // return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => data['']).expand((data) => (data as List)).map((data) {
  //   return Item.fromJSON(data);
  // });
  // return streamedRest.stream
  //     .transform(utf8.decoder)
  //     .transform(json.decoder)
  //     .map((data) {
  //       print("HERE FICE $data");
  //   return AllMarket.fromJSON(data);
  // });
  // return streamedRest.stream
  //     .transform(utf8.decoder)
  //     .transform(json.decoder)
  //     .map((data) => Helper.getData(data))
  //     .expand((data) => (data as List))
  //     .map((data) {
  //   print("HERE TOO $data");
  //   return AllMarket.fromJSON(data);
  // });
}

Future<Stream<Market>> searchMarkets(
    String search, LocationData location) async {
  final String _searchParam =
      'search=name:$search;description:$search&searchFields=name:like;description:like';
  final String _locationParam =
      'myLon=${location.longitude}&myLat=${location.latitude}&areaLon=${location.longitude}&areaLat=${location.latitude}';
  final String _orderLimitParam = 'orderBy=area&limit=5';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}markets?&$_searchParam&$_locationParam&$_orderLimitParam';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Market.fromJSON(data);
  });
}

Future<Stream<Market>> getMarket(String id) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}markets/$id';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .map((data) => Market.fromJSON(data));
}

Future<Stream<Review>> getMarketReviews(String id) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}market_reviews?with=user&search=market_id:$id';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Review.fromJSON(data);
  });
}

Future<Stream<Review>> getRecentReviews() async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}market_reviews?orderBy=updated_at&sortedBy=desc&limit=3&with=user';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Review.fromJSON(data);
  });
}
