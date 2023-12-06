
import '../common/profile_change_notifier.dart';
import '../models/message.dart';

class MessageModel extends ProfileChangeNotifier {
  List<Message> get messages => profile.messages;

  set setMessages(List<Message> messages) {
    if(messages.isNotEmpty){
      profile.messages = messages;
      notifyListeners();
    }
  }

}
