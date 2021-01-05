import 'package:injectable/injectable.dart';
import 'package:pixivic/http/client/artist_rest_client.dart';

import 'package:pixivic/common/do/artist.dart';
import 'package:pixivic/common/do/result.dart';

@lazySingleton
class ArtistService {
  final ArtistRestClient _artistRestClient;

  ArtistService(this._artistRestClient);

  processData(List data) {
    List<Artist> artistList = [];
    data.map((s) => Artist.fromJson(s)).forEach((e) {
      artistList.add(e);
    });
    return artistList;
  }

  Future<Result<List<Artist>>> queryArtistFollowedWithRecentlyIllusts(
      int userId, int page, int pageSize) {
    return _artistRestClient
        .queryFollowedWithRecentlyIllusts(userId, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }

  Future<Result<List<Artist>>> queryArtistSearch(
      String artistName, int page, int pageSize) {
    return _artistRestClient
        .querySearch(artistName, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }
}
