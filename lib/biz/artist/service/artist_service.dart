import 'package:injectable/injectable.dart';

import 'package:pixivic/common/do/artist.dart';
import 'package:pixivic/common/do/result.dart';
import 'package:pixivic/http/client/artist_rest_client.dart';

@lazySingleton
class ArtistService {
  final ArtistRestClient _artistRestClient;

  ArtistService(this._artistRestClient);

  Future<Result<Artist>> queryArtistInfo(int artistId) {
    return _artistRestClient.queryArtistInfo(artistId).then((value) {
      value.data = Artist.fromJson(value.data);
      return value;
    });
  }
}