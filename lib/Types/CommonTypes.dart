enum ItemCategory {
  tops,
  bottoms,
  dresses,
  outerwear,
  activewear,
  accessories,
  others
}

extension ItemCategoryExtension on ItemCategory {
  String get displayName {
    switch (this) {
      case ItemCategory.accessories:
        return "Accessories";
      case ItemCategory.activewear:
        return "Activewear";
      case ItemCategory.bottoms:
        return "Bottoms";
      case ItemCategory.dresses:
        return "Dresses";
      case ItemCategory.others:
        return "Others";
      case ItemCategory.outerwear:
        return "Outerwear";
      case ItemCategory.tops:
        return "Tops";
      default:
        return "";
    }
  }
}

enum ItemSizes { xsMinus, xs, s, m, l, xl, xlPlus }

enum ItemTarget { male, female, unisex }

enum ItemCondition {
  none,
  brandNew,
  likeNew,
  lightlyUsed,
  wellUsed,
  heavilyUsed
}

extension ItemConditionExtension on ItemCondition {
  String get displayName {
    switch (this) {
      case ItemCondition.none:
        return "None";
      case ItemCondition.brandNew:
        return "Brand New";
      case ItemCondition.likeNew:
        return "Like New";
      case ItemCondition.lightlyUsed:
        return "Lightly Used";
      case ItemCondition.wellUsed:
        return "Well Used";
      case ItemCondition.heavilyUsed:
        return "Heavily Used";
      default:
        return "";
    }
  }
}

enum ItemStatus { open, reserved, given }

enum ItemDealOption { delivery, meetup, none }

enum TransactionStatus { give, given, cancel }

class Transaction {
  int giverId;
  int receiverId;
  TransactionStatus status;

  Transaction(this.giverId, this.receiverId, this.status);
}

class Item {
  ItemCategory category;
  ItemSizes size;
  bool isChild;
  ItemTarget target;
  ItemCondition condition;
  String description;
  List<String> photoUrls;
  double longitude;
  double latitude;
  // id of users who like item
  List<int> likes;
  ItemStatus status;
  List<ItemDealOption> dealOptions;
  List<Transaction> transactions;

  Item(
      this.category,
      this.size,
      this.isChild,
      this.target,
      this.condition,
      this.description,
      this.photoUrls,
      this.latitude,
      this.longitude,
      this.likes,
      this.dealOptions,
      this.status,
      this.transactions);
}

class FilterState {
  late ItemCondition? condition;
  late int? minPrice;
  late int? maxPrice;
  late List<ItemDealOption> dealOptions;
  late double distance; // In km

  FilterState.empty() {
    condition = ItemCondition.none;
    minPrice = -1;
    maxPrice = -1;
    distance = 100;
    dealOptions = [];
  }

  FilterState(this.condition, this.dealOptions, this.maxPrice, this.minPrice);
}

