abstract class UserActionsRepository {
  Future<void> blockUser({required String blockerId, required String blockedId});
} 