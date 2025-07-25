import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:data_repository/data_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

part 'create_headline_event.dart';
part 'create_headline_state.dart';

/// A BLoC to manage the state of creating a new headline.
class CreateHeadlineBloc
    extends Bloc<CreateHeadlineEvent, CreateHeadlineState> {
  /// {@macro create_headline_bloc}
  CreateHeadlineBloc({
    required DataRepository<Headline> headlinesRepository,
    required DataRepository<Source> sourcesRepository,
    required DataRepository<Topic> topicsRepository,
    required DataRepository<Country> countriesRepository,
  }) : _headlinesRepository = headlinesRepository,
       _sourcesRepository = sourcesRepository,
       _topicsRepository = topicsRepository,
       _countriesRepository = countriesRepository,
       super(const CreateHeadlineState()) {
    on<CreateHeadlineDataLoaded>(_onDataLoaded);
    on<CreateHeadlineTitleChanged>(_onTitleChanged);
    on<CreateHeadlineExcerptChanged>(_onExcerptChanged);
    on<CreateHeadlineUrlChanged>(_onUrlChanged);
    on<CreateHeadlineImageUrlChanged>(_onImageUrlChanged);
    on<CreateHeadlineSourceChanged>(_onSourceChanged);
    on<CreateHeadlineTopicChanged>(_onTopicChanged);
    on<CreateHeadlineCountryChanged>(_onCountryChanged);
    on<CreateHeadlineStatusChanged>(_onStatusChanged);
    on<CreateHeadlineSubmitted>(_onSubmitted);
  }

  final DataRepository<Headline> _headlinesRepository;
  final DataRepository<Source> _sourcesRepository;
  final DataRepository<Topic> _topicsRepository;
  final DataRepository<Country> _countriesRepository;
  final _uuid = const Uuid();

  Future<void> _onDataLoaded(
    CreateHeadlineDataLoaded event,
    Emitter<CreateHeadlineState> emit,
  ) async {
    emit(state.copyWith(status: CreateHeadlineStatus.loading));
    try {
      final [
        sourcesResponse,
        topicsResponse,
        countriesResponse,
      ] = await Future.wait([
        _sourcesRepository.readAll(),
        _topicsRepository.readAll(),
        _countriesRepository.readAll(),
      ]);

      final sources = (sourcesResponse as PaginatedResponse<Source>).items;
      final topics = (topicsResponse as PaginatedResponse<Topic>).items;
      final countries = (countriesResponse as PaginatedResponse<Country>).items;

      emit(
        state.copyWith(
          status: CreateHeadlineStatus.initial,
          sources: sources,
          topics: topics,
          countries: countries,
        ),
      );
    } on HttpException catch (e) {
      emit(state.copyWith(status: CreateHeadlineStatus.failure, exception: e));
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateHeadlineStatus.failure,
          exception: UnknownException('An unexpected error occurred: $e'),
        ),
      );
    }
  }

  void _onTitleChanged(
    CreateHeadlineTitleChanged event,
    Emitter<CreateHeadlineState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onExcerptChanged(
    CreateHeadlineExcerptChanged event,
    Emitter<CreateHeadlineState> emit,
  ) {
    emit(state.copyWith(excerpt: event.excerpt));
  }

  void _onUrlChanged(
    CreateHeadlineUrlChanged event,
    Emitter<CreateHeadlineState> emit,
  ) {
    emit(state.copyWith(url: event.url));
  }

  void _onImageUrlChanged(
    CreateHeadlineImageUrlChanged event,
    Emitter<CreateHeadlineState> emit,
  ) {
    emit(state.copyWith(imageUrl: event.imageUrl));
  }

  void _onSourceChanged(
    CreateHeadlineSourceChanged event,
    Emitter<CreateHeadlineState> emit,
  ) {
    emit(state.copyWith(source: () => event.source));
  }

  void _onTopicChanged(
    CreateHeadlineTopicChanged event,
    Emitter<CreateHeadlineState> emit,
  ) {
    emit(state.copyWith(topic: () => event.topic));
  }

  void _onCountryChanged(
    CreateHeadlineCountryChanged event,
    Emitter<CreateHeadlineState> emit,
  ) {
    emit(state.copyWith(eventCountry: () => event.country));
  }

  void _onStatusChanged(
    CreateHeadlineStatusChanged event,
    Emitter<CreateHeadlineState> emit,
  ) {
    emit(
      state.copyWith(
        contentStatus: event.status,
        status: CreateHeadlineStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitted(
    CreateHeadlineSubmitted event,
    Emitter<CreateHeadlineState> emit,
  ) async {
    if (!state.isFormValid) return;

    emit(state.copyWith(status: CreateHeadlineStatus.submitting));
    try {
      final now = DateTime.now();
      final newHeadline = Headline(
        id: _uuid.v4(),
        title: state.title,
        excerpt: state.excerpt,
        url: state.url,
        imageUrl: state.imageUrl,
        source: state.source!,
        eventCountry: state.eventCountry!,
        topic: state.topic!,
        createdAt: now,
        updatedAt: now,
        status: state.contentStatus,
      );

      await _headlinesRepository.create(item: newHeadline);
      emit(
        state.copyWith(
          status: CreateHeadlineStatus.success,
          createdHeadline: newHeadline,
        ),
      );
    } on HttpException catch (e) {
      emit(state.copyWith(status: CreateHeadlineStatus.failure, exception: e));
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateHeadlineStatus.failure,
          exception: UnknownException('An unexpected error occurred: $e'),
        ),
      );
    }
  }
}
