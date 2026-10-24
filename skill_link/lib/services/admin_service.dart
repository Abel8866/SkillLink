import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

/// Exception thrown when the Admin Gateway request fails.
class AdminGatewayException implements Exception {
  const AdminGatewayException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

typedef TokenProvider = Future<String?> Function({bool forceRefresh});

class AdminService {
  AdminService({
    http.Client? client,
    this.auth,
    TokenProvider? tokenProvider,
    String? baseUrl,
  }) : _client = client ?? http.Client(),
       _customTokenProvider = tokenProvider,
       _gatewayBaseUrl = baseUrl ?? _defaultBaseUrl;

  static final instance = AdminService();

  static const _defaultBaseUrl =
      'https://ygzueingqcftewiwtnic.supabase.co/functions/v1/admin-registrations';

  final http.Client _client;
  final FirebaseAuth? auth;
  final TokenProvider? _customTokenProvider;
  final String _gatewayBaseUrl;

  /// Checks if the currently authenticated user has the administrator claim.
  Future<bool> isAdmin() async {
    return AuthService.instance.refreshAdminClaim();
  }

  /// Lists provider registrations from the admin gateway.
  Future<List<Map<String, dynamic>>> listRegistrations() async {
    final uri = Uri.parse('$_gatewayBaseUrl/admin/registrations/list');
    final response = await _postWithAuth(uri: uri, body: <String, dynamic>{});
    _validateResponseStatus(response);

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> ||
          decoded['registrations'] is! List) {
        throw const FormatException(
          'The registration list response was invalid.',
        );
      }
      final list = decoded['registrations'] as List;
      return list
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on FormatException catch (error) {
      debugPrint('[AdminService] Invalid list JSON format: ${error.message}');
      throw const AdminGatewayException(
        'The registration list response was invalid.',
      );
    }
  }

  /// Reviews a provider registration (approving or rejecting).
  Future<void> review({
    required String registrationId,
    required String decision,
    String? rejectionReason,
  }) async {
    final uri = Uri.parse('$_gatewayBaseUrl/admin/registrations/review');
    final body = <String, dynamic>{
      'registrationId': registrationId,
      'decision': decision,
      'rejectionReason': rejectionReason,
    };
    final response = await _postWithAuth(uri: uri, body: body);
    _validateResponseStatus(response);

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map || decoded['id'] != registrationId) {
        throw const FormatException(
          'The registration review response was invalid.',
        );
      }
    } on FormatException catch (error) {
      debugPrint('[AdminService] Invalid review JSON format: ${error.message}');
      throw const AdminGatewayException(
        'The registration review response was invalid.',
      );
    }
  }

  Future<String?> _getToken({bool forceRefresh = false}) async {
    if (_customTokenProvider != null) {
      return _customTokenProvider(forceRefresh: forceRefresh);
    }
    final firebaseAuth = auth ?? FirebaseAuth.instance;
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return user.getIdToken(forceRefresh);
  }

  Future<http.Response> _postWithAuth({
    required Uri uri,
    required Map<String, dynamic> body,
  }) async {
    final token = await _getToken(forceRefresh: false);
    if (token == null || token.isEmpty) {
      throw const AdminGatewayException(
        'Authentication is required. Please sign in as an administrator.',
        statusCode: 401,
      );
    }

    final encodedBody = jsonEncode(body);
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    http.Response response;
    try {
      response = await _client.post(uri, headers: headers, body: encodedBody);
    } on http.ClientException catch (error) {
      debugPrint('[AdminService] Network error: ${error.message}');
      throw const AdminGatewayException(
        'Network error connecting to the administration gateway.',
      );
    } on SocketException catch (error) {
      debugPrint('[AdminService] Socket error: ${error.message}');
      throw const AdminGatewayException(
        'Network error connecting to the administration gateway.',
      );
    }

    // On 401 Unauthorized, force-refresh the ID token and retry at most once.
    if (response.statusCode == 401) {
      debugPrint('[AdminService] Received 401. Retrying with fresh ID token.');
      final freshToken = await _getToken(forceRefresh: true);
      if (freshToken == null || freshToken.isEmpty) {
        throw const AdminGatewayException(
          'Authentication failed. Please sign in again.',
          statusCode: 401,
        );
      }

      headers['Authorization'] = 'Bearer $freshToken';
      try {
        response = await _client.post(uri, headers: headers, body: encodedBody);
      } on http.ClientException catch (error) {
        debugPrint('[AdminService] Network error on retry: ${error.message}');
        throw const AdminGatewayException(
          'Network error connecting to the administration gateway.',
        );
      } on SocketException catch (error) {
        debugPrint('[AdminService] Socket error on retry: ${error.message}');
        throw const AdminGatewayException(
          'Network error connecting to the administration gateway.',
        );
      }
    }

    return response;
  }

  void _validateResponseStatus(http.Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) return;

    String? serverMessage;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] is String) {
        serverMessage = decoded['error'] as String;
      }
    } catch (_) {
      // Ignored: body may not be JSON on error
    }

    switch (status) {
      case 400:
        throw AdminGatewayException(
          serverMessage ?? 'The review request was invalid.',
          statusCode: 400,
        );
      case 401:
        throw AdminGatewayException(
          serverMessage ?? 'Authentication is required. Please sign in again.',
          statusCode: 401,
        );
      case 403:
        throw AdminGatewayException(
          serverMessage ?? 'Administrator access is required.',
          statusCode: 403,
        );
      case 404:
        throw AdminGatewayException(
          serverMessage ?? 'The requested registration was not found.',
          statusCode: 404,
        );
      case 409:
        throw AdminGatewayException(
          serverMessage ?? 'This registration has already been reviewed.',
          statusCode: 409,
        );
      case 413:
        throw const AdminGatewayException(
          'The request payload was too large.',
          statusCode: 413,
        );
      default:
        if (status >= 500) {
          throw AdminGatewayException(
            'The administration gateway is temporarily unavailable.',
            statusCode: status,
          );
        }
        throw AdminGatewayException(
          serverMessage ?? 'The administration request could not be completed.',
          statusCode: status,
        );
    }
  }
}
