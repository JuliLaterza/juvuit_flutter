import '../repositories/user_actions_repository.dart';

class BlockUserUseCase {
  final UserActionsRepository repository;

  BlockUserUseCase(this.repository);

  Future<void> call({required String blockerId, required String blockedId}) async {
    await repository.blockUser(blockerId: blockerId, blockedId: blockedId);
  }
} 