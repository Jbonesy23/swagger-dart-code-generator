import 'package:recase/recase.dart';
import 'package:swagger_dart_code_generator/src/exception_words.dart';
import 'package:swagger_dart_code_generator/src/extensions/string_extension.dart';

class EnumModel {
  final String name;
  final List<String> values;
  final bool isInteger;
  final List<String> enumNames;

  static const String defaultEnumFieldName = 'value_';

  const EnumModel({
    required this.name,
    required this.values,
    required this.isInteger,
    required this.enumNames,
  });

  @override
  String toString() => _getEnumContent();

  String _getEnumContent() {
    final resultStrings = <String>[];

    for (int i = 0; i < values.length; i++) {
      final value = values[i];

      var validatedValue = enumNames.isNotEmpty ? enumNames[i] : value;

      validatedValue =
          getValidatedEnumFieldName(validatedValue, value, isInteger);

      if (isInteger) {
        resultStrings.add(
            "\t@JsonValue(${value.replaceAll("\$", "\\\$")})\n\t$validatedValue");
      } else {
        resultStrings.add(
            "\t@JsonValue('${value.replaceAll("\$", "\\\$")}')\n\t$validatedValue");
      }
    }

    return '''
enum $name {
@JsonValue(null)
swaggerGeneratedUnknown(null),

${resultStrings.join(',\n')};

final ${isInteger ? 'int' : 'String'}? value;

const $name(this.value);
}''';
  }


  static String getValidatedEnumFieldName(
      String fieldName, String fieldValue, bool isInteger) {
    if (fieldName.isEmpty) {
      fieldName = 'null';
    }

    var result = fieldName
        .replaceAll(RegExp(r'[^\w|\_|)]'), '_')
        .split('_')
        .where((element) => element.isNotEmpty)
        .map((String word) => word.toLowerCase().capitalize)
        .join();

    if (result.startsWith(RegExp('[0-9]+'))) {
      result = defaultEnumFieldName + result;
    }

    if (exceptionWords.contains(result.toLowerCase())) {
      return '\$${result.lower}(${isInteger ? fieldValue : '\'$fieldValue\''})';
    }

    if (result.isEmpty) {
      return 'undefined(${isInteger ? fieldValue : '\'$fieldValue\''})';
    }

    return '${result.lower}(${isInteger ? fieldValue : '\'$fieldValue\''})';

  }

  String generateFromJsonToJson() {
    final type = isInteger ? 'int' : 'String';

    return '''
$type? ${name.camelCase}ToJson(enums.$name? ${name.camelCase}) {
  return ${name.camelCase}?.value;
}

enums.$name ${name.camelCase}FromJson(
  Object? ${name.camelCase},
  [enums.$name? defaultValue,]
  ) {

return enums.$name.values.firstWhereOrNull((e) => e.value == ${name.camelCase}) ?? defaultValue ?? enums.$name.swaggerGeneratedUnknown;
}


List<$type> ${name.camelCase}ListToJson(
    List<enums.$name>? ${name.camelCase}) {

  if(${name.camelCase} == null)
  {
    return [];
  }

  return ${name.camelCase}
      .map((e) => e.value!)
      .toList();
}

List<enums.$name> ${name.camelCase}ListFromJson(
    List? ${name.camelCase},
    [List<enums.$name>? defaultValue,]) {

  if(${name.camelCase} == null)
  {
    return defaultValue ?? [];
  }

  return ${name.camelCase}
      .map((e) => ${name.camelCase}FromJson(e.toString()))
      .toList();
}


List<enums.$name>? ${name.camelCase}NullableListFromJson(
    List? ${name.camelCase},
    [List<enums.$name>? defaultValue,]) {

  if(${name.camelCase} == null)
  {
    return defaultValue;
  }

  return ${name.camelCase}
      .map((e) => ${name.camelCase}FromJson(e.toString()))
      .toList();
}
    ''';
  }
}
