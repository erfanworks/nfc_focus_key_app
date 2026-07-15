import 'package:get/get.dart';

class FriendModel {
  final String id;
  final String name;
  final String handle;
  final String initials;
  final bool isDarkAvatar;
  final String status;
  final bool isFocusing;

  FriendModel({
    required this.id,
    required this.name,
    required this.handle,
    required this.initials,
    required this.isDarkAvatar,
    required this.status,
    required this.isFocusing,
  });
}

class FriendsController extends GetxController {
  final RxList<FriendModel> addedFriends = <FriendModel>[].obs;

  final List<FriendModel> demoFriends = [
    FriendModel(
      id: '1',
      name: 'Jake',
      handle: '@mk_stydy',
      initials: 'JA',
      isDarkAvatar: true,
      status: 'Focusing now',
      isFocusing: true,
    ),
    FriendModel(
      id: '2',
      name: 'Paul',
      handle: '@pl_focus',
      initials: 'SA',
      isDarkAvatar: false,
      status: 'Focused 2h yesterday',
      isFocusing: false,
    ),
    FriendModel(
      id: '3',
      name: 'Rina',
      handle: '@pl_focus',
      initials: 'RI',
      isDarkAvatar: true,
      status: 'Focusing now',
      isFocusing: true,
    ),
    FriendModel(
      id: '4',
      name: 'Tim',
      handle: '@tim_study',
      initials: 'TI',
      isDarkAvatar: false,
      status: 'Last focused 3h ago',
      isFocusing: false,
    ),
  ];

  void addFriend(FriendModel friend) {
    if (!addedFriends.any((element) => element.id == friend.id)) {
      addedFriends.add(friend);
    }
  }

  bool isFriendAdded(String id) {
    return addedFriends.any((element) => element.id == id);
  }
}
