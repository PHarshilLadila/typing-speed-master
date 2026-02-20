import 'dart:convert';

import 'package:typing_speed_master/models/typing_test_result_model.dart';

// Create a custom codec
class AppExtraCodec extends Codec<Object?, Object?> {
  @override
  Converter<Object?, Object?> get decoder => const AppExtraDecoder();
  @override
  Converter<Object?, Object?> get encoder => const AppExtraEncoder();
}

class AppExtraEncoder extends Converter<Object?, Object?> {
  const AppExtraEncoder();
  @override
  Object? convert(Object? input) {
    // Convert your complex object to a JSON string
    if (input is TypingTestResultModel) {
      return jsonEncode(input.toJson());
    }
    return input;
  }
}

class AppExtraDecoder extends Converter<Object?, Object?> {
  const AppExtraDecoder();
  @override
  Object? convert(Object? input) {
    // Convert the string back to your object
    if (input is String) {
      return TypingTestResultModel.fromJson(jsonDecode(input));
    }
    return input;
  }
}
