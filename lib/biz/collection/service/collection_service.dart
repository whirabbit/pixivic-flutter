import 'package:injectable/injectable.dart';
import 'package:pixivic/common/do/result.dart';
import 'package:pixivic/http/client/collection_rest_client.dart';

@lazySingleton
class CollectionService {
  final CollectionRestClient _collectionRestClient;

  CollectionService(this._collectionRestClient);

  Future<Result> queryCreateCollection(Map body, String authorization) {
    return _collectionRestClient
        .queryCreateCollectionInfo(body, authorization)
        .then((value) {
      return value;
    });
  }

  Future<bool> queryDeleteCollection(int collectionId) {
    return _collectionRestClient
        .queryDeleteCollectionInfo(collectionId)
        .then((value) {
      return value.data as bool;
    });
  }

  Future<Result> queryUpdateCollection(int collectionId, Map body) {
    return _collectionRestClient
        .queryUpdateCollectionInfo(collectionId, body)
        .then((value) {
      return value;
    });
  }

  Future queryBulkDeleteCollection(int collectionId, List<int> illustIds) {
    return _collectionRestClient
        .queryBulkDeleteCollectionInfo(collectionId, illustIds)
        .then((value) {
      return value;
    });
  }

  Future<Result> queryAddIllustToCollection(
      int collectionId, List<int> illustIds) {
    return _collectionRestClient
        .queryAddIllustToCollectionInfo(collectionId, illustIds)
        .then((value) {
      return value;
    });
  }

  Future queryModifyCollectionCover(int collectionId, List<int> illustIds) {
    return _collectionRestClient
        .queryModifyCollectionCoverInfo(collectionId, illustIds)
        .then((value) {
      return value;
    });
  }
}
