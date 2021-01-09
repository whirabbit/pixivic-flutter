import 'package:injectable/injectable.dart';

import 'package:pixivic/common/do/artist.dart';
import 'package:pixivic/common/do/illust.dart';
import 'package:pixivic/http/client/artist_rest_client.dart';

@lazySingleton
class ArtistService {
  final ArtistRestClient _artistRestClient;

  ArtistService(this._artistRestClient);

  processArtistData(List data) {
    List<Artist> artistList = data.map((s) => Artist.fromJson(s)).toList();
    return artistList;
  }

  processIllustData(List data) {
    List<Illust> illustList = data.map((s) => Illust.fromJson(s)).toList();

    return illustList;
  }

  Future<List<Illust>> queryArtistIllustList(
      int artistId, String type, int page, int pageSize, int maxSanityLevel) {
    return _artistRestClient
        .queryArtistIllustListInfo(
            artistId, type, page, pageSize, maxSanityLevel)
        .then((value) {
      if (value.data != null) value.data = processIllustData(value.data);
      return value.data as List<Illust>;
    });
  }

  Future<Artist> querySearchArtistById(
      int artistId, {Function onReceiveProgress}) {
    return _artistRestClient
        .querySearchArtistByIdInfo(artistId,onReceiveProgress)
        .then((value) {
      if (value.data != null) value.data = Artist.fromJson(value.data);
      return value.data as Artist;
    });
  }

  Future<ArtistSummary> queryArtistIllustSummary(int artistId) {
    return _artistRestClient
        .queryArtistIllustSummaryInfo(artistId)
        .then((value) {
      if (value.data != null) value.data = ArtistSummary.fromJson(value.data);
      return value.data as ArtistSummary;
    });
  }

  Future<List<Artist>> querySearchArtist(
      String artistName, int page, int pageSize) {
    return _artistRestClient
        .querySearchArtistInfo(artistName, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processArtistData(value.data);
      return value.data as List<Artist>;
    });
  }
}
