import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:markets_deliveryboy/src/repository/order_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../controllers/order_details_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/ProductOrderItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';

class OrderWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  OrderWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _OrderWidgetState createState() {
    return _OrderWidgetState();
  }
}

class _OrderWidgetState extends StateMVC<OrderWidget>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _tabIndex = 0;
  OrderDetailsController _con;
  final myController = TextEditingController();
  final spendAmountController = TextEditingController();

  _OrderWidgetState() : super(OrderDetailsController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForOrder(id: widget.routeArgument.id);
    _tabController =
        TabController(length: 2, initialIndex: _tabIndex, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  void dispose() {
    _tabController.dispose();
    spendAmountController.dispose();
    myController.dispose();
    super.dispose();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      bottomNavigationBar: _con.order == null
          ? Container(
              height: 193,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).focusColor.withOpacity(0.15),
                        offset: Offset(0, -2),
                        blurRadius: 5.0)
                  ]),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
              ),
            )
          : Container(
              height: _con.order.orderStatus.id == '5' ? 190 : 250,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).focusColor.withOpacity(0.15),
                        offset: Offset(0, -2),
                        blurRadius: 5.0)
                  ]),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            S.of(context).subtotal,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                        Helper.getPrice(
                            Helper.getSubTotalOrdersPrice(_con.order), context,
                            style: Theme.of(context).textTheme.subtitle1)
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            S.of(context).delivery_fee,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                        Helper.getPrice(_con.order.deliveryFee, context,
                            style: Theme.of(context).textTheme.subtitle1)
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${S.of(context).tax} (${_con.order.tax}%)',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                        Helper.getPrice(Helper.getTaxOrder(_con.order), context,
                            style: Theme.of(context).textTheme.subtitle1)
                      ],
                    ),
                    Divider(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            S.of(context).total,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Helper.getPrice(
                            Helper.getTotalOrdersPrice(_con.order), context,
                            style: Theme.of(context).textTheme.headline6)
                      ],
                    ),
                    _con.order.orderStatus.id != '5'
                        ? SizedBox(height: 20)
                        : SizedBox(height: 0),
                    _con.order.orderStatus.id != '5'
                        ? widget.routeArgument.param
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width - 40,
                                child: FlatButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(S
                                                .of(context)
                                                .delivery_confirmation),
                                            content: Container(
                                              height: 280,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    // Text(S
                                                    //     .of(context)
                                                    //     .confirm_delivery_to_client),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    TextFormField(
                                                      controller: myController,
                                                      autocorrect: false,
                                                      style: TextStyle(
                                                          color: Colors.green),
                                                      decoration:
                                                          new InputDecoration(
                                                        // fillColor: Colors.blue,
                                                        focusedBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5.0)),
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .blue)),
                                                        filled: true,
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                top: 10.0,
                                                                left: 10.0,
                                                                right: 10.0),
                                                        labelText:
                                                            "Delivery Code",
                                                      ),
                                                      onSaved:
                                                          (String newValue) {},
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    TextFormField(
                                                      keyboardType:
                                                          TextInputType.number,
                                                      controller:
                                                          spendAmountController,
                                                      autocorrect: false,
                                                      style: TextStyle(
                                                          color: Colors.green),
                                                      decoration:
                                                          new InputDecoration(
                                                        // fillColor: Colors.blue,
                                                        focusedBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5.0)),
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .blue)),
                                                        filled: true,
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                top: 10.0,
                                                                left: 10.0,
                                                                right: 10.0),
                                                        labelText:
                                                            "Enter amount Spend",
                                                      ),
                                                      onSaved:
                                                          (String newValue) {},
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            actions: <Widget>[
                                              // usually buttons at the bottom of the dialog
                                              FlatButton(
                                                child: new Text(
                                                    S.of(context).confirm),
                                                onPressed: () {
                                                  if (myController.text
                                                      .trim()
                                                      .isEmpty) {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          "Add order delivery code.",
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity: ToastGravity.TOP,
                                                      timeInSecForIosWeb: 5,
                                                    );
                                                    return;
                                                  }
                                                  if (spendAmountController.text
                                                      .trim()
                                                      .isEmpty) {
                                                    Fluttertoast.showToast(
                                                      msg: "Add amount spend.",
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity: ToastGravity.TOP,
                                                      timeInSecForIosWeb: 5,
                                                    );
                                                    return;
                                                  }
                                                  _con.doDeliveredOrder(
                                                      _con.order,
                                                      myController.text,
                                                      spendAmountController
                                                          .text);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              FlatButton(
                                                child: new Text(
                                                    S.of(context).dismiss),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  color: Theme.of(context).accentColor,
                                  shape: StadiumBorder(),
                                  child: Text(
                                    S.of(context).delivered,
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .merge(TextStyle(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                  ),
                                ),
                              )
                            : SizedBox(
                                width: MediaQuery.of(context).size.width - 40,
                                child: FlatButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => new CupertinoAlertDialog(
                                        title: new Text("Pick Order"),
                                        content: new Text(
                                            "\nAre you sure you want to pick this order?"),
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
                                              ProgressDialog pr =
                                                  ProgressDialog(context,
                                                      type: ProgressDialogType
                                                          .Normal,
                                                      isDismissible: false,
                                                      showLogs: false);
                                              pr.style(
                                                  message: 'Picking order...');
                                              pr.show();
                                              pickOrder(_con.order)
                                                  .then((value) {
                                                pr.hide();
                                                if (value['status']) {
                                                  Fluttertoast.showToast(
                                                    msg: value['message'],
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity: ToastGravity.TOP,
                                                    timeInSecForIosWeb: 5,
                                                  );
                                                  Navigator.of(context)
                                                      .pushNamed('/Pages',
                                                          arguments: 1);
                                                } else {
                                                  Fluttertoast.showToast(
                                                    msg: value['message'],
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity: ToastGravity.TOP,
                                                    timeInSecForIosWeb: 5,
                                                  );
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  color: Theme.of(context).accentColor,
                                  shape: StadiumBorder(),
                                  child: Text(
                                    "Pick Order",
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .merge(
                                          TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                  ),
                                ),
                              )
                        : SizedBox(height: 10),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
      body: _con.order == null
          ? CircularLoadingWidget(height: 400)
          : CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                snap: true,
                floating: true,
                automaticallyImplyLeading: false,
                leading: new IconButton(
                  icon:
                      new Icon(Icons.sort, color: Theme.of(context).hintColor),
                  onPressed: () => _con.scaffoldKey?.currentState?.openDrawer(),
                ),
                centerTitle: true,
                title: Text(
                  S.of(context).order_details,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .merge(TextStyle(letterSpacing: 1.3)),
                ),
                actions: <Widget>[
                  new ShoppingCartButtonWidget(
                      iconColor: Theme.of(context).hintColor,
                      labelColor: Theme.of(context).accentColor),
                ],
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                expandedHeight: 230,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    margin: EdgeInsets.only(top: 95, bottom: 65),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.1),
                            blurRadius: 5,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).order_id +
                                          ": #${_con.order.id}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                    Text(
                                      _con.order.orderStatus.status,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    Text(
                                      DateFormat('yyyy-MM-dd HH:mm')
                                          .format(_con.order.dateTime),
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Helper.getPrice(
                                      Helper.getTotalOrdersPrice(_con.order),
                                      context,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4),
                                  Text(
                                    _con.order.payment?.method ??
                                        S.of(context).cash_on_delivery,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  Text(
                                    S.of(context).items +
                                            ':' +
                                            _con.order.productOrders?.length
                                                ?.toString() ??
                                        0,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  collapseMode: CollapseMode.pin,
                ),
                bottom: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelPadding: EdgeInsets.symmetric(horizontal: 10),
                    unselectedLabelColor: Theme.of(context).accentColor,
                    labelColor: Theme.of(context).primaryColor,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context).accentColor),
                    tabs: [
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .accentColor
                                      .withOpacity(0.2),
                                  width: 1)),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(S.of(context).ordered_products),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .accentColor
                                      .withOpacity(0.2),
                                  width: 1)),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(S.of(context).customer),
                          ),
                        ),
                      ),
                    ]),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Offstage(
                    offstage: 0 != _tabIndex,
                    child: ListView.separated(
                      padding: EdgeInsets.only(top: 20, bottom: 50),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _con.order.productOrders?.length ?? 0,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 15);
                      },
                      itemBuilder: (context, index) {
                        return ProductOrderItemWidget(
                            heroTag: 'my_orders',
                            order: _con.order,
                            showDeliverOrPickOrder: false,
                            productOrder:
                                _con.order.productOrders.elementAt(index));
                      },
                    ),
                  ),
                  Offstage(
                    offstage: 1 != _tabIndex,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).fullName,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    Text(
                                      _con.order.user.name,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  disabledColor: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.4),
                                  //onPressed: () {
//                                    Navigator.of(context).pushNamed('/Profile',
//                                        arguments: new RouteArgument(param: _con.order.deliveryAddress));
                                  //},
                                  child: Icon(
                                    Icons.person,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                  color: Theme.of(context)
                                      .accentColor
                                      .withOpacity(0.9),
                                  shape: StadiumBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).deliveryAddress,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    Text(
                                      _con.order.deliveryAddress?.address ??
                                          S
                                              .of(context)
                                              .address_not_provided_please_call_the_client,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  disabledColor: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.4),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/Pages',
                                        arguments: new RouteArgument(
                                            id: '3', param: _con.order));
                                  },
                                  child: Icon(
                                    Icons.directions,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                  color: Theme.of(context)
                                      .accentColor
                                      .withOpacity(0.9),
                                  shape: StadiumBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).phoneNumber,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    Text(
                                      _con.order.user.phone,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    launch("tel:${_con.order.user.phone}");
                                  },
                                  child: Icon(
                                    Icons.call,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                  color: Theme.of(context)
                                      .accentColor
                                      .withOpacity(0.9),
                                  shape: StadiumBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              )
            ]),
    );
  }
}
