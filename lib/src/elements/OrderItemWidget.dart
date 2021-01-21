import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:markets_deliveryboy/src/models/all_markets.dart';
import 'package:markets_deliveryboy/src/models/market.dart';
import 'package:markets_deliveryboy/src/repository/order_repository.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/route_argument.dart';
import 'ProductOrderItemWidget.dart';

class OrderItemWidget extends StatefulWidget {
  final bool expanded;
  final bool showDeliverOrPickOrder;
  final Order order;
  final List<Market> markets;

  OrderItemWidget(
      {Key key,
      this.expanded,
      this.order,
      this.showDeliverOrPickOrder,
      this.markets})
      : super(key: key);

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);

    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 14),
              padding: EdgeInsets.only(top: 20, bottom: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Theme(
                data: theme,
                child: ExpansionTile(
                  initiallyExpanded: widget.expanded,
                  title: Column(
                    children: <Widget>[
                      Text('${S.of(context).order_id}: #${widget.order.id}'),
                      Text(
                        DateFormat('dd-MM-yyyy | HH:mm')
                            .format(widget.order.dateTime),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Helper.getPrice(
                          Helper.getTotalOrdersPrice(widget.order), context,
                          style: Theme.of(context).textTheme.headline4),
                      Text(
                        '${widget.order.payment.method}',
                        style: Theme.of(context).textTheme.caption,
                      )
                    ],
                  ),
                  children: <Widget>[
                    Column(
                        children: List.generate(
                      widget.order.productOrders.length,
                      (indexProduct) {
                        return ProductOrderItemWidget(
                            heroTag: 'mywidget.orders',
                            showDeliverOrPickOrder: true,
                            order: widget.order,
                            productOrder: widget.order.productOrders
                                .elementAt(indexProduct));
                      },
                    )),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  S.of(context).delivery_fee,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              Helper.getPrice(widget.order.deliveryFee, context,
                                  style: Theme.of(context).textTheme.subtitle1)
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '${S.of(context).tax} (${widget.order.tax}%)',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              Helper.getPrice(
                                  Helper.getTaxOrder(widget.order), context,
                                  style: Theme.of(context).textTheme.subtitle1)
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  S.of(context).total,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              Helper.getPrice(
                                  Helper.getTotalOrdersPrice(widget.order),
                                  context,
                                  style: Theme.of(context).textTheme.headline4)
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => new CupertinoAlertDialog(
                                      title: new Text("Confirm Cancel Order\n"),
                                      content: Text(
                                          "Are you sure you want to cancel this order?"),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text('Close'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        FlatButton(
                                          child: Text('Yes'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            ProgressDialog pr = ProgressDialog(
                                                context,
                                                type: ProgressDialogType.Normal,
                                                isDismissible: false,
                                                showLogs: false);
                                            pr.style(
                                                message: 'Cancelling order...');
                                            pr.show();
                                            cancelledOrder(widget.order)
                                                .then((value) {
                                              pr.hide();
                                              Fluttertoast.showToast(
                                                msg: value['message'],
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.TOP,
                                                timeInSecForIosWeb: 5,
                                              );
                                              Navigator.of(context)
                                                  .pushNamed('/Pages', arguments: 1);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  height: 28,
                                  width: 140,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(100)),
                                      color: Colors.red),
                                  alignment: AlignmentDirectional.center,
                                  child: Text(
                                    // '${widget.order.orderStatus.status}',
                                    'Cancel Order',
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .merge(TextStyle(
                                            height: 1,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                  ),
                                ),
                              ),
                              Expanded(child: Text("")),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => new CupertinoAlertDialog(
                                      title: new Text("Choose Supplier"),
                                      content: Container(
                                        // color: Colors.blue,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2,
                                        child: ListView.builder(
                                          itemCount: widget.markets.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                // Navigator.of(context).pop();
                                                showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      new CupertinoAlertDialog(
                                                    title: new Text(
                                                        "Assign Supplier"),
                                                    content: new Text(
                                                        "\nAre you sure you want to assign this order to ${widget.markets[index].name} as the supplier?"),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: Text('Close'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      FlatButton(
                                                        child: Text('Yes'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          ProgressDialog pr =
                                                              ProgressDialog(
                                                                  context,
                                                                  type:
                                                                      ProgressDialogType
                                                                          .Normal,
                                                                  isDismissible:
                                                                      false,
                                                                  showLogs:
                                                                      false);
                                                          pr.style(
                                                              message:
                                                                  'Assigning supplier...');
                                                          pr.show();
                                                          assignMarket(
                                                                  widget.order,
                                                                  widget
                                                                      .markets[
                                                                          index]
                                                                      .id)
                                                              .then((value) {
                                                            pr.hide();
                                                            if (value) {
                                                              Fluttertoast
                                                                  .showToast(
                                                                msg:
                                                                    "Assigned successfully",
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                                gravity:
                                                                    ToastGravity
                                                                        .TOP,
                                                                timeInSecForIosWeb:
                                                                    5,
                                                              );
                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(
                                                                      '/Pages',
                                                                      arguments:
                                                                          1);
                                                            } else {
                                                              Fluttertoast
                                                                  .showToast(
                                                                msg:
                                                                    "Unable to Assign supplier",
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                                gravity:
                                                                    ToastGravity
                                                                        .TOP,
                                                                timeInSecForIosWeb:
                                                                    5,
                                                              );
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.black12,
                                                    border: Border.all(
                                                      color: Colors.green,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5))),
                                                margin: EdgeInsets.all(2.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        "${(index + 1)}. ${widget.markets[index].name}",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text('Close'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  height: 28,
                                  width: 140,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(100)),
                                      color: Theme.of(context).accentColor),
                                  alignment: AlignmentDirectional.center,
                                  child: Text(
                                    // '${widget.order.orderStatus.status}',
                                    'Assign Supplier',
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .merge(TextStyle(
                                            height: 1,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              child: Wrap(
                alignment: WrapAlignment.end,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/OrderDetails',
                          arguments:
                              RouteArgument(id: widget.order.id, param: true));
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Wrap(
                      children: <Widget>[
                        Text(S.of(context).viewDetails),
                        Icon(Icons.keyboard_arrow_right)
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text("Supplier: "),
              Expanded(child: Text(" ${widget.order.storeName}")),
            ],
          ),
        ),
      ],
    );
  }
}
