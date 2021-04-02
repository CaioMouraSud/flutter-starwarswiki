import 'dart:async';

import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:starwarswiki/app/models/starship.dart';
import 'package:starwarswiki/app/repository/starships_repository.dart';
import 'package:starwarswiki/app/utils/converters.dart';
import 'package:starwarswiki/code/config.dart';

part 'starships_controller.g.dart';

final _starshipsRepository = StarshipsRepositiry();

class StarshipsController = _StarshipsControllerBase with _$StarshipsController;

abstract class _StarshipsControllerBase with Store {
  @observable
  Box<Starship> _starshipsBox = Hive.box<Starship>(starshipsBox);

  @observable
  List<Starship> starships = [];

  @action
  getStarships({String? nextPage}) async {
    setRes(false);
    if (_starshipsBox.values.isNotEmpty && nextPage == null) {
      starships = _starshipsBox.values.toList();
      setRes(true);
    } else {
      starships = [];
      starships = await _starshipsRepository.fecthStarships(nextPage: nextPage);
      setRes(true);
    }
  }

  @observable
  bool res = true;

  @action
  setRes(newValue) => res = newValue;

  @observable
  String searchText = '';

  @action
  setSearchText(newValue) => searchText = newValue;

  @observable
  int starshipSelected = 0;

  @action
  setStarshipSelected(int newValue) {
    starshipSelected = newValue;
  }

  @computed
  List<Starship> get filterStarships {
    if (searchText == '') {
      return starships;
    } else {
      return starships
          .where((starship) => Converters()
              .simplifyString(starship.name)
              .contains(Converters().simplifyString(searchText)))
          .toList();
    }
  }
}