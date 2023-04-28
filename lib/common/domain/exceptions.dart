import 'package:equatable/equatable.dart';

class AppException extends Equatable{
  final String message;
  const AppException(this.message);
  @override
  List<Object?> get props => [message];
}

enum DBExceptionType{
  platform,
  empty,
  normal
}

class DBException extends AppException{
  final DBExceptionType type;
  const DBException({
    required this.type,
    String message = ''
  }): super(message);
  @override
  List<Object?> get props => [
    ...super.props,
    type
  ];
}

enum StorageExceptionType{
  empty,
  normal
}

class StorageException extends AppException{
  final StorageExceptionType type;
  const StorageException({
    required String message, 
    required this.type
  }): super(
    message
  );
  @override
  List<Object?> get props => [message, type];
}