
import '../common/profile_change_notifier.dart';
import '../models/gpt/chat.dart';

class ChatModel extends ProfileChangeNotifier {
  List<Chat> get chats => profile.chats;

  set setChats(List<Chat> chats) {
    if(chats.isNotEmpty){
      profile.chats = chats;
      notifyListeners();
    }
  }

}
