import '../../domain/repositories/user_actions_repository.dart';
import '../datasources/user_actions_remote_datasource.dart';

class UserActionsRepositoryImpl implements UserActionsRepository {
  final UserActionsRemoteDataSource remoteDataSource;

  UserActionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> blockUser({required String blockerId, required String blockedId}) async {
    await remoteDataSource.blockUser(blockerId: blockerId, blockedId: blockedId);
  }
} 