/// Evaluate the condition from the input value that it is expected to be a specific-type value.
///
/// Also, an optional callback from [next] parameter is used for evaluating the condition value.
/// If there is no callback for [next] parameter, the value from the [next]'s evaluation is always "true".
bool isExpected<V>(
  dynamic value, {
  bool Function(V value)? next,
}) {
  return value is V && (next != null ? next(value) : true);
}
