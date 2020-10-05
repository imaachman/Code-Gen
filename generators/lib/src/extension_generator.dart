import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'package:annotations/annotations.dart';

import 'model_visitor.dart';

class ExtensionGenerator extends GeneratorForAnnotation<ExtensionAnnotation> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return _generatedSource(element);
  }

  String _generatedSource(Element element) {
    var visitor = ModelVisitor();

    element.visitChildren(visitor);

    var classBuffer = StringBuffer();

    // Map 'variables'
    classBuffer.writeln("extension vars on ${visitor.className} {");

    classBuffer.writeln("Map<String, dynamic> get variables =>");

    classBuffer.writeln("{");

    // assign variables to Map
    for (var field in visitor.fields.keys) {
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;

      classBuffer.writeln("'$variable': $field,");
    }

    classBuffer.writeln("};");

    classBuffer.writeln("}");

    // getters and setters
    for (var field in visitor.fields.keys) {
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;

      // extension *variable*Var
      classBuffer.writeln("extension ${variable}Var on ${visitor.className} {");

      // getter
      classBuffer.writeln(
          "${visitor.fields[field]} get $variable => variables['$variable'];");

      // setter
      classBuffer.writeln(
          "set $variable(${visitor.fields[field]} $variable) => $field = $variable;");

      classBuffer.writeln("}");
    }

    return "/*" + classBuffer.toString() + "*/";
  }
}

// extension nameVar on Suck {
//   String get name => variables['name'];

//   set name(String name) => _name = name;
// }

// extension ageVar on Suck {
//   int get age => variables['age'];

//   set age(int age) => _age = age;
// }

// extension sucksVar on Suck {
//   bool get sucks => variables['sucks'];

//   set sucks(bool sucks) => _sucks = sucks;
// }

// extension vars on Suck {
//   Map<String, dynamic> get variables =>
//       {'name': _name, 'age': _age, 'sucks': _sucks};
//   // set variables(Map<String, dynamic> vars) {
//   //   variables['name'] =
//   // }
// }
