// A cross-platform CLI tool to scaffold Flutter & Dart monorepos with Melos 8.x and FVM.
// Run with: dart run scripts/init_workspace.dart [options]
//      or:  fvm dart run scripts/init_workspace.dart [options]

import 'dart:io';

void main(List<String> args) async {
  final options = _parseArgs(args);

  final projectName = options['name'] ?? _getCurrentDirName();
  final packages = (options['packages'] as String?)
          ?.split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList() ??
      <String>[];
  final apps = (options['apps'] as String?)
          ?.split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList() ??
      <String>[];
  final useFvm = options['use-fvm'] == true;
  final gitInit = options['git-init'] == true;

  stdout.writeln('════════════════════════════════════════════════════════════');
  stdout.writeln('  Scaffolding Melos 8 Monorepo: $projectName');
  stdout.writeln('  FVM: $useFvm | Git: $gitInit');
  stdout.writeln('  Packages: $packages');
  stdout.writeln('  Apps: $apps');
  stdout.writeln('════════════════════════════════════════════════════════════\n');

  final scriptDir = File(Platform.script.toFilePath()).parent;
  final templatesDir = Directory('${scriptDir.parent.path}${Platform.pathSeparator}templates');

  // 1. Initialize Git if requested
  if (gitInit) {
    stdout.writeln('-> Initializing Git repository...');
    await _runCommand('git', ['init']);
  }

  // 2. Setup FVM if requested
  if (useFvm) {
    stdout.writeln('-> Configuring FVM...');
    final fvmrcFile = File('.fvmrc');
    if (!fvmrcFile.existsSync()) {
      final template = _readTemplate(templatesDir, 'fvmrc.template', '{"flutter": "stable"}\n');
      await fvmrcFile.writeAsString(template);
    }
    await _runCommand('fvm', ['install']);
    await _runCommand('fvm', ['use', 'stable', '--skip-setup']);
  }

  // 3. Render .gitignore
  stdout.writeln('-> Writing .gitignore...');
  final gitignoreTemplate = _readTemplate(
    templatesDir,
    'gitignore.template',
    '.dart_tool/\nbuild/\npubspec.lock\n.fvm/*\n!.fvm/fvm_config.json\n!.fvm/versions/\n',
  );
  await File('.gitignore').writeAsString(gitignoreTemplate);

  // 4. Render analysis_options.yaml
  stdout.writeln('-> Writing analysis_options.yaml...');
  final analysisTemplate = _readTemplate(
    templatesDir,
    'analysis_options.yaml.template',
    'include: package:lints/recommended.yaml\n',
  );
  await File('analysis_options.yaml').writeAsString(analysisTemplate);

  // 5. Render root pubspec.yaml
  stdout.writeln('-> Writing root pubspec.yaml...');
  final rootPubspecTemplate = _readTemplate(
    templatesDir,
    'root-pubspec.yaml.template',
    _defaultRootPubspec,
  );
  final sdkPathSnippet = useFvm ? '  sdkPath: .fvm/flutter_sdk\n' : '';
  final renderedRootPubspec = rootPubspecTemplate
      .replaceAll('{{PROJECT_NAME}}', projectName)
      .replaceAll('{{MELOS_SDK_PATH_SNIPPET}}', sdkPathSnippet);
  await File('pubspec.yaml').writeAsString(renderedRootPubspec);

  // 6. Scaffold packages/
  Directory('packages').createSync(recursive: true);
  for (final pkg in packages) {
    await _scaffoldPackagePair(templatesDir, pkg);
  }

  // 7. Scaffold apps/
  if (apps.isNotEmpty) {
    Directory('apps').createSync(recursive: true);
    for (final app in apps) {
      await _scaffoldApp(templatesDir, app, packages);
    }
  }

  // 8. Resolve workspace dependencies
  stdout.writeln('\n-> Resolving workspace dependencies...');
  final dartCmd = useFvm ? 'fvm' : 'dart';
  final dartArgs = useFvm ? ['dart', 'pub', 'get'] : ['pub', 'get'];
  await _runCommand(dartCmd, dartArgs);

  stdout.writeln('\n✓ Monorepo $projectName successfully scaffolded!');
  stdout.writeln('Run verification:');
  stdout.writeln('  melos run lint:all');
  stdout.writeln('  melos run test:all\n');
}

Future<void> _scaffoldPackagePair(Directory templatesDir, String pkg) async {
  stdout.writeln('  -> Scaffolding package: ${pkg}_dart (Pure Dart)');
  final dartDir = Directory('packages/${pkg}_dart');
  dartDir.createSync(recursive: true);
  Directory('${dartDir.path}/lib').createSync();
  Directory('${dartDir.path}/test').createSync();

  final dartTemplate = _readTemplate(
    templatesDir,
    'child-dart-pubspec.yaml.template',
    _defaultChildDartPubspec,
  );
  await File('${dartDir.path}/pubspec.yaml')
      .writeAsString(dartTemplate.replaceAll('{{PACKAGE_NAME}}', pkg));
  await File('${dartDir.path}/lib/${pkg}_dart.dart')
      .writeAsString('/// Pure Dart core library for $pkg.\nlibrary;\n\nint calculateMeaning() => 42;\n');
  await File('${dartDir.path}/test/${pkg}_dart_test.dart').writeAsString('''
import 'package:test/test.dart';
import 'package:${pkg}_dart/${pkg}_dart.dart';

void main() {
  test('calculateMeaning returns 42', () {
    expect(calculateMeaning(), equals(42));
  });
}
''');

  stdout.writeln('  -> Scaffolding package: ${pkg}_flutter (Flutter UI)');
  final flutterDir = Directory('packages/${pkg}_flutter');
  flutterDir.createSync(recursive: true);
  Directory('${flutterDir.path}/lib').createSync();
  Directory('${flutterDir.path}/test').createSync();

  final flutterTemplate = _readTemplate(
    templatesDir,
    'child-flutter-pubspec.yaml.template',
    _defaultChildFlutterPubspec,
  );
  await File('${flutterDir.path}/pubspec.yaml')
      .writeAsString(flutterTemplate.replaceAll('{{PACKAGE_NAME}}', pkg));
  await File('${flutterDir.path}/lib/${pkg}_flutter.dart').writeAsString('''
/// Flutter components for $pkg.
library;

export 'package:${pkg}_dart/${pkg}_dart.dart';
''');
  await File('${flutterDir.path}/test/${pkg}_flutter_test.dart').writeAsString('''
import 'package:flutter_test/flutter_test.dart';
import 'package:${pkg}_flutter/${pkg}_flutter.dart';

void main() {
  test('pure dart exports are accessible in flutter package', () {
    expect(calculateMeaning(), equals(42));
  });
}
''');
}

Future<void> _scaffoldApp(Directory templatesDir, String app, List<String> packages) async {
  stdout.writeln('  -> Scaffolding app: $app');
  final appDir = Directory('apps/$app');
  appDir.createSync(recursive: true);
  Directory('${appDir.path}/lib').createSync();
  Directory('${appDir.path}/test').createSync();

  final deps = StringBuffer();
  for (final pkg in packages) {
    deps.writeln('  ${pkg}_flutter:');
  }

  await File('${appDir.path}/pubspec.yaml').writeAsString('''
name: $app
description: Application or sandbox catalog for $app.
version: 0.1.0
publish_to: none

environment:
  sdk: '>=3.13.0 <4.0.0'
  flutter: '>=3.47.0'

resolution: workspace

dependencies:
  flutter:
    sdk: flutter
$deps
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
''');

  await File('${appDir.path}/lib/main.dart').writeAsString('''
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('$app')))));
}
''');
}

String _readTemplate(Directory templatesDir, String filename, String fallback) {
  final file = File('${templatesDir.path}/$filename');
  if (file.existsSync()) {
    return file.readAsStringSync();
  }
  return fallback;
}

Future<void> _runCommand(String executable, List<String> arguments) async {
  try {
    final result = await Process.run(executable, arguments, runInShell: true);
    if (result.exitCode != 0) {
      stderr.writeln('Command failed: $executable ${arguments.join(' ')}');
      stderr.writeln(result.stderr);
    }
  } catch (e) {
    stderr.writeln('Could not execute $executable: $e');
  }
}

String _getCurrentDirName() {
  final dir = Directory.current.path;
  final parts = dir.split(Platform.pathSeparator);
  return parts.isNotEmpty ? parts.last.replaceAll('-', '_') : 'my_monorepo';
}

Map<String, dynamic> _parseArgs(List<String> args) {
  final map = <String, dynamic>{};
  for (final arg in args) {
    if (arg.startsWith('--name=')) {
      map['name'] = arg.substring('--name='.length);
    } else if (arg.startsWith('--packages=')) {
      map['packages'] = arg.substring('--packages='.length);
    } else if (arg.startsWith('--apps=')) {
      map['apps'] = arg.substring('--apps='.length);
    } else if (arg == '--use-fvm') {
      map['use-fvm'] = true;
    } else if (arg == '--git-init') {
      map['git-init'] = true;
    }
  }
  return map;
}

const _defaultRootPubspec = '''
name: {{PROJECT_NAME}}_repo
publish_to: none

environment:
  sdk: '>=3.13.0 <4.0.0'

workspace:
  - packages/**
  - apps/**

dev_dependencies:
  melos: ^8.9.0
  lints: ^5.0.0

melos:
{{MELOS_SDK_PATH_SNIPPET}}
  scripts:
    analyze:
      run: dart analyze .
    test:all:
      run: melos test --no-pub
''';

const _defaultChildDartPubspec = '''
name: {{PACKAGE_NAME}}_dart
version: 0.1.0
publish_to: none

environment:
  sdk: '>=3.13.0 <4.0.0'

resolution: workspace

dev_dependencies:
  test: ^1.25.0
  lints: ^5.0.0
''';

const _defaultChildFlutterPubspec = '''
name: {{PACKAGE_NAME}}_flutter
version: 0.1.0
publish_to: none

environment:
  sdk: '>=3.13.0 <4.0.0'
  flutter: '>=3.47.0'

resolution: workspace

dependencies:
  flutter:
    sdk: flutter
  {{PACKAGE_NAME}}_dart:

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
''';
