part of 'create_source_bloc.dart';

/// Base class for all events related to the [CreateSourceBloc].
sealed class CreateSourceEvent extends Equatable {
  const CreateSourceEvent();

  @override
  List<Object?> get props => [];
}

/// Event to signal that the data for dropdowns should be loaded.
final class CreateSourceDataLoaded extends CreateSourceEvent {
  const CreateSourceDataLoaded();
}

/// Event for when the source's name is changed.
final class CreateSourceNameChanged extends CreateSourceEvent {
  const CreateSourceNameChanged(this.name);
  final String name;
  @override
  List<Object?> get props => [name];
}

/// Event for when the source's description is changed.
final class CreateSourceDescriptionChanged extends CreateSourceEvent {
  const CreateSourceDescriptionChanged(this.description);
  final String description;
  @override
  List<Object?> get props => [description];
}

/// Event for when the source's URL is changed.
final class CreateSourceUrlChanged extends CreateSourceEvent {
  const CreateSourceUrlChanged(this.url);
  final String url;
  @override
  List<Object?> get props => [url];
}

/// Event for when the source's type is changed.
final class CreateSourceTypeChanged extends CreateSourceEvent {
  const CreateSourceTypeChanged(this.sourceType);
  final SourceType? sourceType;
  @override
  List<Object?> get props => [sourceType];
}

/// Event for when the source's language is changed.
final class CreateSourceLanguageChanged extends CreateSourceEvent {
  const CreateSourceLanguageChanged(this.language);
  final String language;
  @override
  List<Object?> get props => [language];
}

/// Event for when the source's headquarters is changed.
final class CreateSourceHeadquartersChanged extends CreateSourceEvent {
  const CreateSourceHeadquartersChanged(this.headquarters);
  final Country? headquarters;
  @override
  List<Object?> get props => [headquarters];
}

/// Event for when the source's status is changed.
final class CreateSourceStatusChanged extends CreateSourceEvent {
  const CreateSourceStatusChanged(this.status);

  final ContentStatus status;

  @override
  List<Object?> get props => [status];
}

/// Event to signal that the form should be submitted.
final class CreateSourceSubmitted extends CreateSourceEvent {
  const CreateSourceSubmitted();
}
