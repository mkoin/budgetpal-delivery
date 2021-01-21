import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markets_deliveryboy/src/models/payout.dart';
import 'package:markets_deliveryboy/src/repository/order_repository.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../repository/user_repository.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final myController = TextEditingController();
  final myPinController = TextEditingController();
  List<Payout> payouts = <Payout>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshEarnings();
  }

  _refreshEarnings() async {
    await refreshDriver(currentUser.value).then((value) {
      setState(() {
        //this.favorite = value;
      });
    });

    final Stream<Payout> stream = await getDriversPayouts();
    stream.listen((Payout _order) {
      setState(() {
        payouts.add(_order);
      });
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    myController.dispose();
    myPinController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Earnings"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(5),
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).accentColor.withOpacity(0.2),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text("Current Balance",
                        style: Theme.of(context).textTheme.headline1),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Ksh.${currentUser.value.earnings.toString()}",
                        style: Theme.of(context).textTheme.headline4),
                    SizedBox(
                      height: 20,
                    ),
                    RaisedButton.icon(
                      color: Colors.green,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Cash Out"),
                                content: Container(
                                  height: 150,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        // Text(S
                                        //     .of(context)
                                        //     .confirm_delivery_to_client),
                                        TextFormField(
                                          controller: myController,
                                          keyboardType: TextInputType.number,
                                          autocorrect: false,
                                          style: TextStyle(color: Colors.green),
                                          decoration: new InputDecoration(
                                            // fillColor: Colors.blue,
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.blue)),
                                            filled: true,
                                            contentPadding: EdgeInsets.only(
                                                top: 10.0,
                                                left: 10.0,
                                                right: 10.0),
                                            labelText: "Amount",
                                          ),
                                          onSaved: (String newValue) {},
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        TextFormField(
                                          obscureText: true,
                                          controller: myPinController,
                                          autocorrect: false,
                                          style: TextStyle(color: Colors.green),
                                          decoration: new InputDecoration(
                                            // fillColor: Colors.blue,
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.blue)),
                                            filled: true,
                                            contentPadding: EdgeInsets.only(
                                                top: 10.0,
                                                left: 10.0,
                                                right: 10.0),
                                            labelText: "Enter Pin",
                                          ),
                                          onSaved: (String newValue) {},
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  FlatButton(
                                    child: new Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: new Text("Cash Out"),
                                    onPressed: () {
                                      if (myController.text.trim().isEmpty) {
                                        Fluttertoast.showToast(
                                          msg: "Add order delivery code.",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.TOP,
                                          timeInSecForIosWeb: 5,
                                        );
                                        return;
                                      }
                                      // Navigator.of(context).pop();
                                      ProgressDialog pr = ProgressDialog(
                                          context,
                                          type: ProgressDialogType.Normal,
                                          isDismissible: true,
                                          showLogs: false);
                                      pr.style(
                                          message: 'Processing cashout...');
                                      pr.show();
                                      cashOut(myController.text, "m-Pesa",
                                              myPinController.text)
                                          .then((value) {
                                        if (value['status']) {
                                          refreshDriver(currentUser.value)
                                              .then((value) {
                                            setState(() {
                                              //this.favorite = value;
                                            });
                                          });
                                          Navigator.of(context)
                                              .pushReplacementNamed('/Wallet');
                                        }
                                        pr.hide();
                                        Navigator.of(context).pop();
                                        Fluttertoast.showToast(
                                          msg: value['message'],
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.TOP,
                                          timeInSecForIosWeb: 5,
                                        );
                                      });
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      label: Text(
                        "Cash out",
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).accentColor.withOpacity(0.2),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Text("Earnings",
                            style: Theme.of(context).textTheme.headline5),
                        Expanded(
                          child: Text(""),
                        ),
                        Text("Ksh.${currentUser.value.earnings.toString()}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Text("Tips",
                            style: Theme.of(context).textTheme.headline5),
                        Expanded(
                          child: Text(""),
                        ),
                        Text(
                          "Ksh.00",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Transaction History",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(5),
                height: 300,
                child: ListView.builder(
                  itemCount: payouts.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {},
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  Text("Ksh.${payouts[index].amount}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6),
                                  Expanded(child: Text("")),
                                  Text(
                                    "${payouts[index].note}",
                                  ),
                                ],
                              ),
                              Text(
                                payouts[index].paid_date,
                                style: Theme.of(context).textTheme.caption,
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
