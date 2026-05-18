import 'dart:math';

import 'package:skeletonizer/skeletonizer.dart';
import 'package:vibin_app/dtos/tags/tag.dart';
import 'package:vibin_app/extensions.dart';

List<Tag> getMockedTagList(int count) {
  var rand = Random();
  return List.generate(count, (i) {
    return Tag(
      id: 0,
      name: randomString(rand.nextInt(10) + 5),
      description: BoneMock.subtitle,
      importance: rand.nextInt(10),
      createdAt: 1779115233,
      updatedAt: 1779115233
    );
  });
}