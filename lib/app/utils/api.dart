import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:starwarswiki/app/components/snack_bar_widget.dart';

import '../app_controller.dart';

import 'package:http/http.dart' as http;

final _appController = Modular.get<AppController>();

SnackBarWidget snackBarWidget = SnackBarWidget();

class API {
  bool canceled = false;

  cancel() => this.canceled = true;

  Future getApi(String link, Function success, Function error,
      BuildContext context) async {
    try {
      get(link) {
        return http.get(Uri.parse(link)).then((res) async {
          if (this.canceled) return;
          var jsonData;
          if (res.statusCode == 404 || res.body.isEmpty) {
            error('Erro ao conectar ao servidor, tente novamente mais tarde.');
          } else if (res.statusCode == 200) {
            jsonData = json.decode(res.body);
            if (jsonData != null) {
              success(jsonData);
            } else {
              error(jsonData);
            }
          } else if (res.statusCode == 201) {
            jsonData = json.decode(res.body);
            if (jsonData['status'] == 'success') {
              success(jsonData);
            } else {
              error(jsonData);
            }
          }
        });
      }

      if (_appController.noInternet) {
        snackBarWidget.show(context, 'Sem internet.');
      } else {
        get(link);
      }
    } on SocketException catch (_) {
      snackBarWidget.show(
          context, 'Erro ao conectar ao servidor, tente novamente mais tarde.');
    }
  }
}