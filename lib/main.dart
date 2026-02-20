import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'layouts/admin_layout.dart';
import 'providers/regex_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/tools_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/regex_builder_screen.dart';
import 'screens/regex_samples_screen.dart';
import 'screens/json_formatter_screen.dart';
import 'screens/base64_screen.dart';
import 'screens/url_encoder_screen.dart';
import 'screens/hash_generator_screen.dart';
import 'screens/uuid_generator_screen.dart';
import 'screens/timestamp_converter_screen.dart';
import 'screens/lorem_ipsum_screen.dart';
import 'screens/jwt_decoder_screen.dart';
import 'screens/color_converter_screen.dart';
import 'screens/case_converter_screen.dart';
import 'screens/number_base_converter_screen.dart';
import 'screens/diff_viewer_screen.dart';
import 'screens/sql_formatter_screen.dart';
import 'screens/cron_builder_screen.dart';
import 'screens/qr_generator_screen.dart';
import 'screens/markdown_preview_screen.dart';
import 'screens/password_generator_screen.dart';
import 'screens/api_request_screen.dart';
import 'screens/data_converter_screen.dart';
import 'screens/code_beautifier_screen.dart';
import 'screens/image_tools_screen.dart';
import 'screens/html_entity_screen.dart';
import 'screens/string_escape_screen.dart';
import 'screens/text_analyzer_screen.dart';
import 'screens/regex_cheatsheet_screen.dart';
import 'screens/websocket_tester_screen.dart';
import 'screens/git_tools_screen.dart';
import 'screens/data_generator_screen.dart';
import 'screens/network_tools_screen.dart';
import 'screens/unicode_tools_screen.dart';
import 'screens/env_manager_screen.dart';
import 'screens/encryption_tools_screen.dart';
import 'screens/docker_tools_screen.dart';
import 'screens/snippet_manager_screen.dart';
import 'screens/enhanced_diff_screen.dart';
import 'screens/ssl_tools_screen.dart';
import 'screens/webhook_tester_screen.dart';
import 'screens/deeplink_tester_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  final toolsProvider = ToolsProvider();

  await Future.wait([themeProvider.initialize(), toolsProvider.initialize()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => RegexProvider()),
        ChangeNotifierProvider.value(value: toolsProvider),
      ],
      child: const DevToolsApp(),
    ),
  );
}

class DevToolsApp extends StatelessWidget {
  const DevToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProvider, __) {
        return MaterialApp(
          title: 'DevTools Pro - Developer Utilities Suite',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            Widget screen;

            switch (settings.name) {
              case '/':
                screen = const DashboardScreen();
                break;
              case '/regex-builder':
                screen = const RegexBuilderScreen();
                break;
              case '/regex-samples':
                screen = const RegexSamplesScreen();
                break;
              case '/json-formatter':
                screen = const JsonFormatterScreen();
                break;
              case '/base64':
                screen = const Base64Screen();
                break;
              case '/url-encoder':
                screen = const UrlEncoderScreen();
                break;
              case '/hash-generator':
                screen = const HashGeneratorScreen();
                break;
              case '/uuid-generator':
                screen = const UuidGeneratorScreen();
                break;
              case '/timestamp':
                screen = const TimestampConverterScreen();
                break;
              case '/lorem-ipsum':
                screen = const LoremIpsumScreen();
                break;
              case '/jwt-decoder':
                screen = const JwtDecoderScreen();
                break;
              case '/color-converter':
                screen = const ColorConverterScreen();
                break;
              case '/case-converter':
                screen = const CaseConverterScreen();
                break;
              case '/number-base':
                screen = const NumberBaseConverterScreen();
                break;
              case '/diff-viewer':
                screen = const DiffViewerScreen();
                break;
              case '/sql-formatter':
                screen = const SqlFormatterScreen();
                break;
              case '/cron-builder':
                screen = const CronBuilderScreen();
                break;
              case '/qr-generator':
                screen = const QrGeneratorScreen();
                break;
              case '/markdown-preview':
                screen = const MarkdownPreviewScreen();
                break;
              case '/password-generator':
                screen = const PasswordGeneratorScreen();
                break;
              case '/api-request':
                screen = const ApiRequestScreen();
                break;
              case '/data-converter':
                screen = const DataConverterScreen();
                break;
              case '/code-beautifier':
                screen = const CodeBeautifierScreen();
                break;
              case '/image-tools':
                screen = const ImageToolsScreen();
                break;
              case '/html-entity':
                screen = const HtmlEntityScreen();
                break;
              case '/string-escape':
                screen = const StringEscapeScreen();
                break;
              case '/text-analyzer':
                screen = const TextAnalyzerScreen();
                break;
              case '/regex-cheatsheet':
                screen = const RegexCheatsheetScreen();
                break;
              case '/websocket-tester':
                screen = const WebsocketTesterScreen();
                break;
              case '/git-tools':
                screen = const GitToolsScreen();
                break;
              case '/data-generator':
                screen = const DataGeneratorScreen();
                break;
              case '/network-tools':
                screen = const NetworkToolsScreen();
                break;
              case '/unicode-tools':
                screen = const UnicodeToolsScreen();
                break;
              case '/env-manager':
                screen = const EnvManagerScreen();
                break;
              case '/encryption-tools':
                screen = const EncryptionToolsScreen();
                break;
              case '/docker-tools':
                screen = const DockerToolsScreen();
                break;
              case '/snippet-manager':
                screen = const SnippetManagerScreen();
                break;
              case '/enhanced-diff':
                screen = const EnhancedDiffScreen();
                break;
              case '/ssl-tools':
                screen = const SslToolsScreen();
                break;
              case '/webhook-tester':
                screen = const WebhookTesterScreen();
                break;
              case '/deeplink-tester':
                screen = const DeepLinkTesterScreen();
                break;
              default:
                screen = const DashboardScreen();
            }

            return MaterialPageRoute(
              builder: (_) =>
                  AdminLayout(currentRoute: settings.name, child: screen),
              settings: settings,
            );
          },
        );
      },
    );
  }
}
