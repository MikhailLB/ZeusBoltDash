import 'dart:convert';
import '../config/bolt_config.dart';
import '../models/gate_types.dart';
import 'zeus_agent.dart';
import 'flash_vault.dart';

class BoltDispatch {
  final FlashVault _vault;
  BoltDispatch(this._vault);

  Future<BoltReply> send(Map<String, dynamic> body) async {
    final endpoint = BoltConfig.configEndpoint;
    if (endpoint.isEmpty) return BoltReply.declined('endpoint_missing');
    try {
      final uri = Uri.parse(endpoint);
      final resp = await zeusAgent
          .post(uri,
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return BoltReply.declined('http_${resp.statusCode}');
      final decoded = jsonDecode(resp.body);
      if (decoded is! Map<String, dynamic>) return BoltReply.declined('bad_json');
      final reply = BoltReply.fromMap(decoded);
      if (reply.granted && reply.destination != null) {
        await _vault.writeSavedUrl(reply.destination!);
        if (reply.expiresAt != null) await _vault.writeSavedTtl(reply.expiresAt!);
      }
      return reply;
    } catch (err) {
      return BoltReply.declined(err.toString());
    }
  }
}
