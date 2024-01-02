import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'messages_cs.dart' as messages_cs;
import 'messages_da.dart' as messages_da;
import 'messages_de.dart' as messages_de;
import 'messages_el.dart' as messages_el;
import 'messages_en.dart' as messages_en;
import 'messages_es.dart' as messages_es;
import 'messages_fi.dart' as messages_fi;
import 'messages_fr.dart' as messages_fr;
import 'messages_he.dart' as messages_he;
import 'messages_hu.dart' as messages_hu;
import 'messages_it.dart' as messages_it;
import 'messages_ja.dart' as messages_ja;
import 'messages_ko.dart' as messages_ko;
import 'messages_nl.dart' as messages_nl;
import 'messages_pl.dart' as messages_pl;
import 'messages_pt.dart' as messages_pt;
import 'messages_ru.dart' as messages_ru;
import 'messages_sl.dart' as messages_sl;
import 'messages_sv.dart' as messages_sv;
import 'messages_tr.dart' as messages_tr;
import 'messages_zh_cn.dart' as messages_zh_cn;

typedef LibraryLoader = Future<dynamic> Function();

Map<String, LibraryLoader> _deferredLibraries = {
  'cs': () => Future.value('cs'),
  'da': () => Future.value('da'),
  'de': () => Future.value('de'),
  'el': () => Future.value('el'),
  'en': () => Future.value( 'en'),
  'es': () => Future.value('es'),
  'fi': () => Future.value('fi'),
  'fr': () => Future.value('fr'),
  'he': () => Future.value('he'),
  'hu': () => Future.value('hu'),
  'it': () => Future.value('it'),
  'ja': () => Future.value('ja'),
  'ko': () => Future.value('ko'),
  'nl': () => Future.value('nl'),
  'pl': () => Future.value('pl'),
  'pt': () => Future.value('pt'),
  'ru': () => Future.value('ru'),
  'sl': () => Future.value('sl'),
  'sv': () => Future.value('sv'),
  'tr': () => Future.value('tr'),
  'zh_CN': () => Future.value('zh_CN'),
};

MessageLookupByLibrary? _findExact(String localeName) {
  switch (localeName) {
    case 'cs':
      return messages_cs.messages;
    case 'da':
      return messages_da.messages;
    case 'de':
      return messages_de.messages;
    case 'el':
      return messages_el.messages;
    case 'en':
      return messages_en.messages;
    case 'es':
      return messages_es.messages;
    case 'fi':
      return messages_fi.messages;
    case 'fr':
      return messages_fr.messages;
    case 'he':
      return messages_he.messages;
    case 'hu':
      return messages_hu.messages;
    case 'it':
      return messages_it.messages;
    case 'ja':
      return messages_ja.messages;
    case 'ko':
      return messages_ko.messages;
    case 'nl':
      return messages_nl.messages;
    case 'pl':
      return messages_pl.messages;
    case 'pt':
      return messages_pt.messages;
    case 'ru':
      return messages_ru.messages;
    case 'sl':
      return messages_sl.messages;
    case 'sv':
      return messages_sv.messages;
    case 'tr':
      return messages_tr.messages;
    case 'zh_CN':
      return messages_zh_cn.messages;
    default:
      return messages_en.messages;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) async {
  var availableLocale = Intl.verifiedLocale(
      localeName, (locale) => _deferredLibraries[locale] != null,
      onFailure: (_) => null);
  if (availableLocale == null) {
    return Future.value(false);
  }
  var lib = _deferredLibraries[availableLocale];
  await (lib == null ? Future.value(false) : lib());
  initializeInternalMessageLookup(() => CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return Future.value(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary? _findGeneratedMessagesFor(String locale) {
  var actualLocale =
      Intl.verifiedLocale(locale, _messagesExistFor, onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
