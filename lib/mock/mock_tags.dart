import 'package:skeletonizer/skeletonizer.dart';
import 'package:vibin_app/dtos/tags/tag.dart';

List<Tag> getMockedTagList(int count) {
  return List.filled(count, Tag(
    id: 0,
    name: BoneMock.name,
    description: BoneMock.subtitle,
    importance: 0,
    createdAt: 1779115233,
    updatedAt: 1779115233
  ));
}