import 'package:swagger_generator/src/code_generators/v3/swagger_additions_generator_v3.dart';
import 'package:test/test.dart';

void main() {
  group('Additions generator tests', () {
    final SwaggerAdditionsGeneratorV3 _generator =
        SwaggerAdditionsGeneratorV3();

    test('Should generate mapping for files', () {
      final String result =
          _generator.generateConverterMappings(<String, List<String>>{
        'someFile.dart': <String>['someFile.swagger.dart'],
        'secondFile.dart': <String>['secondFile.swagger.dart']
      });

      expect(result, contains('...SomeFileJsonDecoderMappings'));
      expect(result, contains('...SecondFileJsonDecoderMappings'));
    });

    test('Should generate correct imports', () {
      final String result =
          _generator.generateImportsContent('swagger.fileName', true);

      expect(result, contains("part 'swagger.fileName.swagger.chopper.dart';"));
      expect(result, contains("part 'swagger.fileName.swagger.g.dart';"));
    });

    test('Should generate indexes file', () {
      final String result = _generator.generateIndexes(<String, List<String>>{
        'someFile.dart': <String>['someFile.swagger.dart'],
        'secondFile.dart': <String>['secondFile.swagger.dart']
      });

      expect(result, contains("import 'someFile.dart.dart' show SomeFile;"));
      expect(
          result, contains("import 'secondFile.dart.dart' show SecondFile;"));
    });
  });

  group('Test for generateCustomJsonConverter', () {
    final SwaggerAdditionsGeneratorV3 _generator =
        SwaggerAdditionsGeneratorV3();
    test('Should generate custom json converter', () {
      const String fileName = 'example_swagger';
      const String expectedResult =
          'CustomJsonDecoder(ExampleSwaggerJsonDecoderMappings)';
      final String result = _generator.generateCustomJsonConverter(fileName);

      expect(result, contains(expectedResult));
    });
  });
}