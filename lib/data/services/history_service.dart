import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Kaydedilmiş bir tefsir (bookmark).
class SavedTafsir {
  final String id;
  final String question;
  final String answer;
  final String surahRefs; // "Sure 2, Ayet 255" gibi
  final DateTime date;
  const SavedTafsir({required this.id, required this.question, required this.answer, required this.surahRefs, required this.date});

  Map<String, dynamic> toJson() => {'id': id, 'question': question, 'answer': answer, 'surahRefs': surahRefs, 'date': date.toIso8601String()};
  factory SavedTafsir.fromJson(Map<String, dynamic> j) => SavedTafsir(id: j['id'], question: j['question'], answer: j['answer'], surahRefs: j['surahRefs'] ?? '', date: DateTime.parse(j['date']));
}

/// Sohbet oturumu.
class ChatHistorySession {
  final String id;
  final String title;
  final String preview;
  final DateTime date;
  const ChatHistorySession({required this.id, required this.title, required this.preview, required this.date});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'preview': preview, 'date': date.toIso8601String()};
  factory ChatHistorySession.fromJson(Map<String, dynamic> j) => ChatHistorySession(id: j['id'], title: j['title'], preview: j['preview'] ?? '', date: DateTime.parse(j['date']));
}

/// Yerel depolama servisi.
class HistoryService {
  HistoryService._();
  static const _keySessions = 'chat_sessions';
  static const _keySaved = 'saved_tafsirs';

  // ─── SOHBET OTURUMLARI ───
  static Future<List<ChatHistorySession>> getSessions() async {
    final raw = (await SharedPreferences.getInstance()).getString(_keySessions);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((j) => ChatHistorySession.fromJson(j)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> addSession(ChatHistorySession session) async {
    final list = await getSessions();
    list.removeWhere((s) => s.id == session.id);
    list.insert(0, session);
    // En fazla 50 oturum sakla
    if (list.length > 50) list.removeRange(50, list.length);
    await _saveSessions(list);
  }

  static Future<void> deleteSession(String id) async {
    final list = await getSessions();
    list.removeWhere((s) => s.id == id);
    await _saveSessions(list);
  }

  static Future<void> _saveSessions(List<ChatHistorySession> list) async {
    await (await SharedPreferences.getInstance()).setString(_keySessions, jsonEncode(list.map((s) => s.toJson()).toList()));
  }

  // ─── KAYDEDİLEN TEFSİRLER ───
  static Future<List<SavedTafsir>> getSaved() async {
    final raw = (await SharedPreferences.getInstance()).getString(_keySaved);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((j) => SavedTafsir.fromJson(j)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> addSaved(SavedTafsir tafsir) async {
    final list = await getSaved();
    list.removeWhere((s) => s.id == tafsir.id);
    list.insert(0, tafsir);
    if (list.length > 100) list.removeRange(100, list.length);
    await (await SharedPreferences.getInstance()).setString(_keySaved, jsonEncode(list.map((s) => s.toJson()).toList()));
  }

  static Future<void> removeSaved(String id) async {
    final list = await getSaved();
    list.removeWhere((s) => s.id == id);
    await (await SharedPreferences.getInstance()).setString(_keySaved, jsonEncode(list.map((s) => s.toJson()).toList()));
  }

  static Future<bool> isSaved(String id) async {
    final list = await getSaved();
    return list.any((s) => s.id == id);
  }
}
