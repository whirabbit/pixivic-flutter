import 'package:injectable/injectable.dart';

import 'package:pixivic/common/do/Artist.dart';
import 'package:pixivic/common/do/Result.dart';
import 'package:pixivic/http/client/ArtistRestClient.dart';

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