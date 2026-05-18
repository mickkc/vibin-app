import 'package:skeletonizer/skeletonizer.dart';
import 'package:vibin_app/dtos/user/user.dart';

User getMockedUser() {
  return User(
      0, BoneMock.name, BoneMock.name, BoneMock.subtitle,
      null, BoneMock.email, true, false, 1779115233, 1779115233, 1779115233);
}

List<User> getMockedUserList(int count) {
  return List.filled(count, getMockedUser());
}