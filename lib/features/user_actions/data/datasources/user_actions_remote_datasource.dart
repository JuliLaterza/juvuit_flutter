import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserActionsRemoteDataSource {
  Future<void> blockUser({required String blockerId, required String blockedId});
}

class UserActionsRemoteDataSourceImpl implements UserActionsRemoteDataSource {
  final FirebaseFirestore firestore;

  UserActionsRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> blockUser({required String blockerId, required String blockedId}) async {
    await firestore
        .collection('users')
        .doc(blockerId)
        .collection('blocked')
        .doc(blockedId)
        .set({'blockedAt': FieldValue.serverTimestamp()});
  }
} 