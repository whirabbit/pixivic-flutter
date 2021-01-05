import 'package:injectable/injectable.dart';
import 'package:pixivic/http/client/illust_rest_client.dart';

import 'package:pixivic/common/do/illust.dart';
import 'package:pixivic/common/do/result.dart';

@lazySingleton
class IllustService {
  final IllustRestClient _illustRestClient;

  IllustService(this._illustRestClient);

  processData(List data) {
    List<Illust> illustList = [];
    data.map((s) => Illust.fromJson(s)).forEach((e) {
      illustList.add(e);
    });
    return illustList;
  }

  Future<Result<List<Illust>>> queryIllustRank(
      String date, String mode, int page, int pageSize) {
    return _illustRestClient
        .queryRank(date, mode, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }

  Future<Result<List<Illust>>> queryIllustRelated(
      num relatedId, int page, int pageSize) {
    return _illustRestClient
        .queryRelated(relatedId, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }

  Future<Result<List<Illust>>> queryIllustSearch(
      String keyword, int page, int pageSize) {
    return _illustRestClient.querySearch(page, keyword, pageSize).then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }

  Future<Result<List<Illust>>> queryIllustArtist(String artistId, String type,
      int page, int pageSize, int maxSanityLevel) {
    return _illustRestClient
        .queryArtist(artistId, type, page, pageSize, maxSanityLevel)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }

  Future<Result<List<Illust>>> queryIllustFollowed(
      String userId, String type, int page, int pageSize) {
    return _illustRestClient
        .queryFollowed(userId, type, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }

  Future<Result<List<Illust>>> queryIllustBookmark(
      String userId, String type, int page, int pageSize) {
    return _illustRestClient
        .queryBookmark(userId, type, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }

  Future<Result<List<Illust>>> queryIllustSpotlight(String spotlightId) {
    return _illustRestClient.querySpotlight(spotlightId).then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }

  Future<Result<List<Illust>>> queryIllustHistory(
      String userId, int page, int pageSize) {
    return _illustRestClient.queryHistory(userId, page, pageSize).then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }

  Future<Result<List<Illust>>> queryIllustOldHistory(
      String userId, int page, int pageSize) {
    return _illustRestClient
        .queryOldHistory(userId, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }

  Future<Result<List<Illust>>> queryIllustCollection(
      String collectionId, int page, int pageSize) {
    return _illustRestClient
        .queryCollection(collectionId, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }
}
