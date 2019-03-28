Map<String, Object> deepMerge(
    Map<String, dynamic> first, Map<String, dynamic> second) {
  final Map<String, dynamic> result = {};

  []
    ..addAll(first.keys)
    ..addAll(second.keys)
    ..forEach((key) {
      if (first.containsKey(key) && !second.containsKey(key)) {
        result[key] = first[key];
      } else if (!first.containsKey(key) && second.containsKey(key)) {
        result[key] = second[key];
      } else {
        if (first[key] is Iterable && second[key] is Iterable) {
          result[key] = []..addAll(first[key])..addAll(second[key]);
        } else if (first[key] is Map && second[key] is Map) {
          result[key] = deepMerge(first[key], second[key]);
        } else {
          result[key] = second[key];
        }
      }
    });

  return result;
}
