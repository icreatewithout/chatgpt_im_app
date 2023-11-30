class Api {
  // static const String baseUrl = "http://192.168.3.47:8080";
  static const String baseUrl = "http://192.168.3.30:8080";
  static const String releaseUrl = "https://api.opencn.info";

  static const String sendCode = "/auth/send/by/";
  static const String login = "/auth/login/by/";
  static const String logout = "/auth/logout";

  /// course
  static const String courseList = "/zh/open-cn/course/v-1.0/list";
  static const String course = "/zh/open-cn/course/v-1.0/";

  /// banner
  static const String bannerList = "/zh/open-cn/banner/v-1.0/list";

  //column
  static const String columnList = "/zh/open-cn/column/v-1.0/list";

  //content /open-cn/content
  static const String topList = "/zh/open-cn/content/v-1.0/top/";
  static const String contentList = "/zh/open-cn/content/v-1.0/list";
  static const String contentDetail = "/zh/open-cn/content/v-1.0/detail/";

}
