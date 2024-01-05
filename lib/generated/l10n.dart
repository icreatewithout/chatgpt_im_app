import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final String name =
        locale.countryCode!.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;
      return instance;
    });
  }

  static S of(BuildContext context) {
    final S? instance = Localizations.of<S>(context, S);
    return instance!;
  }

  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  String get logoutTip {
    return Intl.message('OK to log out! ',
        name: 'logoutTip', desc: '', args: []);
  }

  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  String get ok {
    return Intl.message('Ok', name: 'ok', desc: '', args: []);
  }

  String get loginTip {
    return Intl.message('You are not Logged in',
        name: 'loginTip', desc: '', args: []);
  }

  String get find {
    return Intl.message('OpenAi', name: 'find', desc: '', args: []);
  }

  String get qa {
    return Intl.message('Forum', name: 'qa', desc: '', args: []);
  }

  String get infoQ {
    return Intl.message('InfoQ', name: 'infoQ', desc: '', args: []);
  }

  String get me {
    return Intl.message('Me', name: 'me', desc: '', args: []);
  }

  String get deleteAccount {
    return Intl.message('Delete Account',
        name: 'deleteAccount', desc: '', args: []);
  }

  String get hintText1 {
    return Intl.message('By joining OpenGPT, you agree to OpenGPT’s',
        name: 'hintText1', desc: '', args: []);
  }

  String get hintText2 {
    return Intl.message('Terms of Service and Privacy Policy',
        name: 'hintText2', desc: '', args: []);
  }

  String get loginAnonymously {
    return Intl.message('Log in anonymously',
        name: 'loginAnonymously', desc: '', args: []);
  }

  String get emailLogin {
    return Intl.message('Email Login', name: 'emailLogin', desc: '', args: []);
  }

  String get googleLogin {
    return Intl.message('Google Login',
        name: 'googleLogin', desc: '', args: []);
  }

  String get xLogin {
    return Intl.message('X Login', name: 'xLogin', desc: '', args: []);
  }

  String get facebookLogin {
    return Intl.message('Facebook Login',
        name: 'facebookLogin', desc: '', args: []);
  }

  String get like {
    return Intl.message('like', name: 'like', desc: '', args: []);
  }

  String get comment {
    return Intl.message('comment', name: 'comment', desc: '', args: []);
  }

  String get tosapp {
    return Intl.message('Terms of Service and Privacy Policy',
        name: 'tosapp', desc: '', args: []);
  }

  String get selectAudioFile {
    return Intl.message('Select audio file',
        name: 'selectAudioFile', desc: '', args: []);
  }

  String get inputContent {
    return Intl.message('Please enter content',
        name: 'inputContent', desc: '', args: []);
  }

  String get selectModel {
    return Intl.message('Select Model',
        name: 'selectModel', desc: '', args: []);
  }

  String get gptName {
    return Intl.message('Name', name: 'gptName', desc: '', args: []);
  }

  String get gptHintText {
    return Intl.message('Please enter name',
        name: 'gptHintText', desc: '', args: []);
  }

  String get gptInstructions {
    return Intl.message('Instructions',
        name: 'gptInstructions', desc: '', args: []);
  }

  String get gpDes {
    return Intl.message('Description', name: 'gpDes', desc: '', args: []);
  }

  String get gptDefaultDesVal {
    return Intl.message('Please enter a description',
        name: 'gptDefaultDesVal', desc: '', args: []);
  }

  String get gptDesHintText {
    return Intl.message('For example,smart assistant',
        name: 'gptDesHintText', desc: '', args: []);
  }

  String get gptTemperature {
    return Intl.message('Temperature',
        name: 'gptTemperature', desc: '', args: []);
  }

  String get gptDefaultVal {
    return Intl.message('Default value:',
        name: 'gptDefaultVal', desc: '', args: []);
  }

  String get gptMessages {
    return Intl.message('Number of historical messages, default value: 1',
        name: 'gptMessages', desc: '', args: []);
  }

  String get delChat {
    return Intl.message('Delete chat', name: 'delChat', desc: '', args: []);
  }

  String get updateSetting {
    return Intl.message('Setting', name: 'updateSetting', desc: '', args: []);
  }

  String get hint {
    return Intl.message('prompt', name: 'hint', desc: '', args: []);
  }

  String get hintDelChat {
    return Intl.message('Are you sure to delete it?',
        name: 'hintDelChat', desc: '', args: []);
  }

  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  String get code {
    return Intl.message('Code', name: 'code', desc: '', args: []);
  }

  String get sendCode {
    return Intl.message('Send Code', name: 'sendCode', desc: '', args: []);
  }

  String get sendDone {
    return Intl.message('Code sent', name: 'sendDone', desc: '', args: []);
  }

  String get inputCode {
    return Intl.message('please enter verification code',
        name: 'inputCode', desc: '', args: []);
  }

  String get inputEmail {
    return Intl.message('please input your email',
        name: 'inputEmail', desc: '', args: []);
  }

  String get emailErr {
    return Intl.message('Email format error',
        name: 'emailErr', desc: '', args: []);
  }

  String get emailHint {
    return Intl.message(
        'Enter your email, receive and fill in the verification code',
        name: 'emailHint',
        desc: '',
        args: []);
  }

  String get verify {
    return Intl.message('Verify', name: 'verify', desc: '', args: []);
  }

  String get setting {
    return Intl.message('Setting', name: 'setting', desc: '', args: []);
  }

  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  String get editInfo {
    return Intl.message('Edit information',
        name: 'editInfo', desc: '', args: []);
  }

  String get shareMe {
    return Intl.message('Share', name: 'shareMe', desc: '', args: []);
  }

  String get commentText {
    return Intl.message('Comment', name: 'commentText', desc: '', args: []);
  }

  String get likeText {
    return Intl.message('Like', name: 'likeText', desc: '', args: []);
  }

  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  String get saveComment {
    return Intl.message('please enter a comment',
        name: 'saveComment', desc: '', args: []);
  }

  String get inputComment {
    return Intl.message('please enter your opinion',
        name: 'inputComment', desc: '', args: []);
  }

  String get replay {
    return Intl.message('Reply', name: 'replay', desc: '', args: []);
  }

  String get moreComment {
    return Intl.message('expand more', name: 'moreComment', desc: '', args: []);
  }

  String get open {
    return Intl.message('expand', name: 'open', desc: '', args: []);
  }

  String get openMun {
    return Intl.message('replies', name: 'openMun', desc: '', args: []);
  }

  String get limitSize {
    return Intl.message('You can only select up to 9 pictures',
        name: 'limitSize', desc: '', args: []);
  }

  String get hintText {
    return Intl.message('Write down your thoughts...',
        name: 'hintText', desc: '', args: []);
  }

  String get addImage {
    return Intl.message('add pictures', name: 'addImage', desc: '', args: []);
  }

  String get photoGranted {
    return Intl.message('Not allowed to obtain album permissions',
        name: 'photoGranted', desc: '', args: []);
  }

  String get storageGranted {
    return Intl.message('Not allowed to obtain storage permissions',
        name: 'storageGranted', desc: '', args: []);
  }

  String get avatar {
    return Intl.message('avatar', name: 'avatar', desc: '', args: []);
  }

  String get nickname {
    return Intl.message('nickname ', name: 'nickname', desc: '', args: []);
  }

  String get mine {
    return Intl.message('mine', name: 'mine', desc: '', args: []);
  }

  String get feedback {
    return Intl.message('write your question...', name: 'feedback', desc: '', args: []);
  }

  String get myContent {
    return Intl.message('My Content', name: 'myContent', desc: '', args: []);
  }

  String get myComment {
    return Intl.message('My Comment', name: 'myComment', desc: '', args: []);
  }

  String get views {
    return Intl.message('Views', name: 'views', desc: '', args: []);
  }

  String get fb {
    return Intl.message('Feedback', name: 'fb', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'cs'),
      Locale.fromSubtags(languageCode: 'da'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'el'),
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fi'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'he'),
      Locale.fromSubtags(languageCode: 'hu'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'sl'),
      Locale.fromSubtags(languageCode: 'sv'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode.contains(locale.languageCode)) {
        return true;
      }
    }
    return false;
  }
}
