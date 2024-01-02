dart run intl_generator:extract_to_arb --output-dir=lib/l10n lib/generated/l10n.dart
dart run intl_generator:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/generated/l10n.dart lib/l10n/intl_*.arb
