import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'package:annotations/annotations.dart';

import 'model_visitor.dart';

class SubclassGenerator extends GeneratorForAnnotation<SubclassAnnotation> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return _generatedSource(element);
  }

  String _generatedSource(Element element) {
    var visitor = ModelVisitor();

    element.visitChildren(visitor);

    var className = "${visitor.className}Gen";

    var classBuffer = StringBuffer();

    // class *Model*Gen
    classBuffer.writeln("class $className extends ${visitor.className} {");

    // initialize Map 'variables'
    classBuffer.writeln("Map<String, dynamic> variables = {};");

    // constructor
    classBuffer.writeln("$className() {");

    // assign variables to Map
    for (var field in visitor.fields.keys) {
      // remove '_' from private variables
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;

      classBuffer.writeln("variables['${variable}'] = super.$field;");
    }
    

    // constructor close
    classBuffer.writeln("}");

    // getters and setters
    for (var field in visitor.fields.keys) {
      // remove '_' from private variables
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;

      // getter
      classBuffer.writeln(
          "${visitor.fields[field]} get $variable => variables['$variable'];");

      // setter
      classBuffer.writeln("set $variable(${visitor.fields[field]} meh) {");

      classBuffer.writeln("super.$field = meh;");

      classBuffer.writeln("variables['$variable'] = meh;");

      classBuffer.writeln("}");
    }

    // class ends here
    classBuffer.writeln("}");

    return "/*" + classBuffer.toString() + "*/";
  }
}
