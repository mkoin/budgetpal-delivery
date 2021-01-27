import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  const CustomTextField({Key key, this.hintText, this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return   Padding(
      padding: const EdgeInsets.only(left:12, right: 12, bottom: 12),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 0.2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  offset: Offset(2, 1),
                  blurRadius: 2
              )
            ]
        ),
        child: Padding(
          padding: const EdgeInsets.only(left:8.0),
          child: TextField(
            keyboardType: TextInputType.number,
            controller: controller,
            decoration: InputDecoration(
                icon: Icon(Icons.phone_android, color: Colors.grey),
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                    color: Colors.grey,
                    fontFamily: "Sen",
                    fontSize: 18
                )
            ),
          ),
        ),
      ),
    );

  }
}