import 'package:dart_openai/dart_openai.dart';

class OpenAiUtils {

  // 获取系统模型
  Future<List<OpenAIModelModel>> getModels(String apiKey) async {
    OpenAI.apiKey = apiKey;
    return await OpenAI.instance.model.list();
  }

}
