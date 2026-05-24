import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/bolt_config.dart';
import '../models/bolt_reply.dart';
import 'zeus_agent.dart';
import 'flash_vault.dart';

class BoltDispatch {
  final FlashVault _vault;
  BoltDispatch(this._vault);

  Future<BoltReply> send(Map<String, dynamic> body) async {
    final endpoint = BoltConfig.configEndpoint;
    debugPrint('[ZBD.BD] send → "$endpoint"');
    if (endpoint.isEmpty) return BoltReply.declined('endpoint_missing');
    try {
      final uri = Uri.parse(endpoint);
      final resp = await zeusAgent
          .post(uri,
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 8));
      debugPrint('[ZBD.BD] HTTP ${resp.statusCode}');
      if (resp.statusCode != 200) return BoltReply.declined('http_${resp.statusCode}');
      final decoded = jsonDecode(resp.body);
      if (decoded is! Map<String, dynamic>) return BoltReply.declined('bad_json');
      final reply = BoltReply.fromMap(decoded);
      debugPrint('[ZBD.BD] granted=${reply.granted} dest=${reply.destination}');
      if (reply.granted && reply.destination != null) {
        await _vault.writeSavedUrl(reply.destination!);
        if (reply.expiresAt != null) await _vault.writeSavedTtl(reply.expiresAt!);
      }
      return reply;
    } catch (err) {
      debugPrint('[ZBD.BD] error: $err');
      return BoltReply.declined(err.toString());
    }
  }
}
