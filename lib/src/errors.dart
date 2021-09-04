/// The error instance that represent the web service request problem.
abstract class WebServiceResponseError extends Error {}

/// The error instance that represent the server responding 400 (Bad Request) http code.
class BadRequestError extends WebServiceResponseError {
  BadRequestError() : super();
}

/// The error instance that represent the server responding 401 (Unauthorized) http code.
class UnauthorizedError extends WebServiceResponseError {
  UnauthorizedError() : super();
}

/// The error instance that represent the server responding USER_NOT_FOUND
/// error.
class UserNotFoundError extends WebServiceResponseError {
  UserNotFoundError() : super();
}

/// The error instance that represent the server responding PASSWORD_INCORRECT
/// error.
class PasswordIncorrectError extends WebServiceResponseError {
  PasswordIncorrectError() : super();
}

/// The error instance that represent the server responding USERNAME_EXIST
/// error.
class UsernameExistError extends WebServiceResponseError {
  UsernameExistError() : super();
}

/// The error instance that represent the server responding USER_INFO_MODIFYING_FAILED
/// error.
class UserInfoModifyingError extends WebServiceResponseError {
  UserInfoModifyingError() : super();
}

/// The error instance that represent the server responding USER_PASSWORD_CHANGING_FAILED
/// error.
class UserPasswordChangingError extends WebServiceResponseError {
  UserPasswordChangingError() : super();
}

/// The error instance that represent the server responding RECORD_CREATED_FAILED
/// error.
class RecordCreatingError extends WebServiceResponseError {
  RecordCreatingError() : super();
}

/// The error instance that represent the server responding RECORD_MODIFYING_FAILED
/// error.
class RecordModifyingError extends WebServiceResponseError {
  RecordModifyingError() : super();
}

/// The error instance that represent the server responding PATIENT_CREATING_FAILED
/// error.
class PatientCreatingError extends WebServiceResponseError {
  PatientCreatingError() : super();
}

/// The error instance that represent the server responding PATIENT_SELF_CREATING_FAILED
/// error.
class PatientSelfCreatingError extends WebServiceResponseError {
  PatientSelfCreatingError() : super();
}

/// The error instance that represent the server responding PATIENT_MODIFYING_FAILED
/// error.
class PatientModifyingError extends WebServiceResponseError {
  PatientModifyingError() : super();
}

/// The error instance that represent the server responding CERTIFICATE_CREATING_FAILED
/// error.
class CertificateCreatingError extends WebServiceResponseError {
  CertificateCreatingError() : super();
}

/// The error instance that represent the server responding CERTIFICATE_MODIFYING_FAILED
/// error.
class CertificateModifyingError extends WebServiceResponseError {
  CertificateModifyingError() : super();
}

/// The error instance that represent the server responding CERTIFICATE_HEADER_MODIFYING_ERROR
/// error.
class CertificateHeaderModifyingError extends WebServiceResponseError {
  CertificateHeaderModifyingError() : super();
}

/// The error instance that represent the server responding UNEXPECTED_ERROR
/// error, or some troubles on requesting occured.
class UnexpectedResponseError extends WebServiceResponseError {
  UnexpectedResponseError() : super();
}

/// The error instance that represent the client-side problem.
abstract class ClientError extends Error {}

/// The error instance that represent the lack of authentication key for using
/// in web service request.
class NoAuthenticationKeyError extends ClientError {
  NoAuthenticationKeyError() : super();
}

/// The error instance that represent the form validation detects the wrong input field.
class FormValidationError extends ClientError {
  FormValidationError() : super();
}

/// The error instance that represent the unknown error.
class UnknownError extends Error {
  /// The error.
  final dynamic error;
  UnknownError(this.error) : super();
}
