import 'package:injectable/injectable.dart';

import 'package:pixivic/common/do/illust.dart';
import 'package:pixivic/common/do/result.dart';
import 'package:pixivic/common/do/spotlight.dart';
import 'package:pixivic/http/client/spotlight_rest_client.dart';

@lazySingleton
class SpotlightService {
  final SpotlightRestClient _spotlightRestClient;

  SpotlightService(this._spotlightRestClient);

  processIllustData(List data) {
    List<Illust> illustList = [];
    data.map((s) => Illust.fromJson(s)).forEach((e) {
      illustList.add(e);
    });
    return illustList;
  }

  processSpotlightData(List data) {
    List<Spotlight> spotlightList = [];
    data.map((s) => Spotlight.fromJson(s)).forEach((e) {
      spotlightList.add(e);
    });
    return spotlightList;
  }

  Future<Result<List<Spotlight>>> querySpotlightList(int page, int pageSize) {
    return _spotlightRestClient
        .querySpotlightListInfo(page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processSpotlightData(value.data);
      return value;
    });
  }

  Future<Result<List<Illust>>> querySpotlightIllustList(int spotlightId) {
    return _spotlightRestClient
        .querySpotlightIllustListInfo(spotlightId)
        .then((value) {
      if (value.data != null) value.data = processIllustData(value.data);
      return value;
    });
  }
}
