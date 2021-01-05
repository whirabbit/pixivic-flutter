import 'package:injectable/injectable.dart';

import 'package:pixivic/common/do/artist_detail.dart';
import 'package:pixivic/common/do/result.dart';
import 'package:pixivic/http/client/artist_detail_rest_client.dart';

@lazySingleton
class ArtistDetailService {
  final ArtistDetailRestClient _artistDetailRestClient;

  ArtistDetailService(this._artistDetailRestClient);

  Future<Result<ArtistDetail>> queryArtistDetail(int artistId) {
    return _artistDetailRestClient
        .queryArtistDetailInfo(artistId)
        .then((value) {
      value.data = ArtistDetail.fromJson(value.data);
      return value;
    });
  }
  Future<Result<ArtistSummary>> queryArtistSummary(int artistId) {
    return _artistDetailRestClient
        .queryArtistSummaryInfo(artistId)
        .then((value) {
      value.data = ArtistSummary.fromJson(value.data);
      return value;
    });
  }
}
