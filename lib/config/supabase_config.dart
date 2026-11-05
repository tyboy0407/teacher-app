/// Supabase 連線設定。
///
/// 未提供時 App 會改用內建示範資料,設定方式見專案根目錄的 SUPABASE_SETUP.md:
/// flutter run --dart-define-from-file=supabase.env.json
/// (或逐一指定 --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...)
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
