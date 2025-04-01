// ignore_for_file: non_nullable_equals_parameter

class DropDownObject extends Object {
  final String itemName;
  final String? key;

  DropDownObject({
    this.key,
    required this.itemName,
  });

  bool subItems() {
    return false;
  }

  @override
  String toString() {
    return itemName;
  }

  @override
  bool operator ==(dynamic other) {
    return other != null && key == other.key && itemName == other.itemName;
  }

  @override
  int get hashCode => super.hashCode;
}

class DropDownStrObject extends Object {
  final String itemId;
  final String itemName;

  DropDownStrObject({
    required this.itemId,
    required this.itemName,
  });

  bool subItems() {
    return false;
  }

  @override
  String toString() {
    return itemName;
  }

  @override
  bool operator ==(dynamic other) {
    return other != null && itemId == other.itemId;
  }

  @override
  int get hashCode => super.hashCode;
}
