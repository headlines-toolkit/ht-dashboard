//
// ignore_for_file: deprecated_member_use

import 'package:auth_repository/auth_repository.dart';
import 'package:core/core.dart' hide AppStatus;
// Import for app_theme.dart
import 'package:data_repository/data_repository.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_news_app_web_dashboard_full_source_code/app/bloc/app_bloc.dart';
import 'package:flutter_news_app_web_dashboard_full_source_code/app/config/app_environment.dart';
import 'package:flutter_news_app_web_dashboard_full_source_code/app_configuration/bloc/app_configuration_bloc.dart';
import 'package:flutter_news_app_web_dashboard_full_source_code/authentication/bloc/authentication_bloc.dart';
import 'package:flutter_news_app_web_dashboard_full_source_code/content_management/bloc/content_management_bloc.dart';
import 'package:flutter_news_app_web_dashboard_full_source_code/dashboard/bloc/dashboard_bloc.dart';
import 'package:flutter_news_app_web_dashboard_full_source_code/l10n/app_localizations.dart';
import 'package:flutter_news_app_web_dashboard_full_source_code/router/router.dart';
import 'package:go_router/go_router.dart';
import 'package:kv_storage_service/kv_storage_service.dart';
import 'package:logging/logging.dart';
import 'package:ui_kit/ui_kit.dart';

class App extends StatelessWidget {
  const App({
    required AuthRepository authenticationRepository,
    required DataRepository<Headline> headlinesRepository,
    required DataRepository<Topic> topicsRepository,
    required DataRepository<Country> countriesRepository,
    required DataRepository<Source> sourcesRepository,
    required DataRepository<UserAppSettings> userAppSettingsRepository,
    required DataRepository<UserContentPreferences>
    userContentPreferencesRepository,
    required DataRepository<RemoteConfig> remoteConfigRepository,
    required DataRepository<DashboardSummary> dashboardSummaryRepository,
    required KVStorageService storageService,
    required AppEnvironment environment,
    super.key,
  }) : _authenticationRepository = authenticationRepository,
       _headlinesRepository = headlinesRepository,
       _topicsRepository = topicsRepository,
       _countriesRepository = countriesRepository,
       _sourcesRepository = sourcesRepository,
       _userAppSettingsRepository = userAppSettingsRepository,
       _userContentPreferencesRepository = userContentPreferencesRepository,
       _remoteConfigRepository = remoteConfigRepository,
       _kvStorageService = storageService,
       _dashboardSummaryRepository = dashboardSummaryRepository,
       _environment = environment;

  final AuthRepository _authenticationRepository;
  final DataRepository<Headline> _headlinesRepository;
  final DataRepository<Topic> _topicsRepository;
  final DataRepository<Country> _countriesRepository;
  final DataRepository<Source> _sourcesRepository;
  final DataRepository<UserAppSettings> _userAppSettingsRepository;
  final DataRepository<UserContentPreferences>
  _userContentPreferencesRepository;
  final DataRepository<RemoteConfig> _remoteConfigRepository;
  final DataRepository<DashboardSummary> _dashboardSummaryRepository;
  final KVStorageService _kvStorageService;
  final AppEnvironment _environment;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authenticationRepository),
        RepositoryProvider.value(value: _headlinesRepository),
        RepositoryProvider.value(value: _topicsRepository),
        RepositoryProvider.value(value: _countriesRepository),
        RepositoryProvider.value(value: _sourcesRepository),
        RepositoryProvider.value(value: _userAppSettingsRepository),
        RepositoryProvider.value(value: _userContentPreferencesRepository),
        RepositoryProvider.value(value: _remoteConfigRepository),
        RepositoryProvider.value(value: _dashboardSummaryRepository),
        RepositoryProvider.value(value: _kvStorageService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppBloc(
              authenticationRepository: context.read<AuthRepository>(),
              userAppSettingsRepository: context
                  .read<DataRepository<UserAppSettings>>(),
              appConfigRepository: context.read<DataRepository<RemoteConfig>>(),
              environment: _environment,
              logger: Logger('AppBloc'),
            ),
          ),
          BlocProvider(
            create: (context) => AuthenticationBloc(
              authenticationRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => AppConfigurationBloc(
              remoteConfigRepository: context
                  .read<DataRepository<RemoteConfig>>(),
            ),
          ),
          BlocProvider(
            create: (context) => ContentManagementBloc(
              headlinesRepository: context.read<DataRepository<Headline>>(),
              topicsRepository: context.read<DataRepository<Topic>>(),
              sourcesRepository: context.read<DataRepository<Source>>(),
            ),
          ),
          BlocProvider(
            create: (context) => DashboardBloc(
              dashboardSummaryRepository: context
                  .read<DataRepository<DashboardSummary>>(),
              headlinesRepository: context.read<DataRepository<Headline>>(),
            ),
          ),
        ],
        child: _AppView(
          authenticationRepository: _authenticationRepository,
          environment: _environment,
        ),
      ),
    );
  }
}

class _AppView extends StatefulWidget {
  /// {@macro app_view}
  const _AppView({
    required this.authenticationRepository,
    required this.environment,
  });

  final AuthRepository authenticationRepository;
  final AppEnvironment environment;

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final GoRouter _router;
  late final ValueNotifier<AppStatus> _statusNotifier;

  @override
  void initState() {
    super.initState();
    final appBloc = context.read<AppBloc>();
    _statusNotifier = ValueNotifier<AppStatus>(appBloc.state.status);
    _router = createRouter(
      authStatusNotifier: _statusNotifier,
      authenticationRepository: widget.authenticationRepository,
      environment: widget.environment,
    );
  }

  @override
  void dispose() {
    _statusNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.userAppSettings != current.userAppSettings,
      listener: (context, state) {
        _statusNotifier.value = state.status;
      },
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final userAppSettings = state.userAppSettings;
          final baseTheme = userAppSettings?.displaySettings.baseTheme;
          final accentTheme = userAppSettings?.displaySettings.accentTheme;
          final fontFamily = userAppSettings?.displaySettings.fontFamily;
          final textScaleFactor =
              userAppSettings?.displaySettings.textScaleFactor;
          final fontWeight = userAppSettings?.displaySettings.fontWeight;
          final language = userAppSettings?.language;

          final lightThemeData = lightTheme(
            scheme: accentTheme?.toFlexScheme ?? FlexScheme.materialHc,
            appTextScaleFactor: textScaleFactor ?? AppTextScaleFactor.medium,
            appFontWeight: fontWeight ?? AppFontWeight.regular,
            fontFamily: fontFamily,
          );

          final darkThemeData = darkTheme(
            scheme: accentTheme?.toFlexScheme ?? FlexScheme.materialHc,
            appTextScaleFactor: textScaleFactor ?? AppTextScaleFactor.medium,
            appFontWeight: fontWeight ?? AppFontWeight.regular,
            fontFamily: fontFamily,
          );

          const double kMaxAppWidth = 1000; // Local constant for max width
          return Center(
            child: Card(
              margin: EdgeInsets.zero, // Remove default card margin
              elevation: 4, // Add some elevation to make it "pop"
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ), // Match cardRadius from theme
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxAppWidth),
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  routerConfig: _router,
                  localizationsDelegates: const [
                    UiKitLocalizations.delegate,
                    ...AppLocalizations.localizationsDelegates,
                  ],
                  supportedLocales: UiKitLocalizations.supportedLocales,
                  theme: baseTheme == AppBaseTheme.dark
                      ? darkThemeData
                      : lightThemeData,
                  darkTheme: darkThemeData,
                  themeMode: switch (baseTheme) {
                    AppBaseTheme.light => ThemeMode.light,
                    AppBaseTheme.dark => ThemeMode.dark,
                    _ => ThemeMode.system,
                  },
                  locale: language != null ? Locale(language) : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

extension AppAccentThemeExtension on AppAccentTheme {
  FlexScheme get toFlexScheme {
    switch (this) {
      case AppAccentTheme.defaultBlue:
        return FlexScheme.materialHc;
      case AppAccentTheme.newsRed:
        return FlexScheme.redWine;
      case AppAccentTheme.graphiteGray:
        return FlexScheme.outerSpace;
    }
  }
}
