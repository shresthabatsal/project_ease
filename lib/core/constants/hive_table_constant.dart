class HiveTableConstant {
  HiveTableConstant._();

  static const dbName = "ease_db";

  static const int userTypeId = 0;
  static const String userTable = "user_table";

  static const String productsTable   = 'products';
  static const String categoriesTable = 'categories';

  static const int productTypeId    = 10;
  static const int categoryTypeId   = 11;

  static String productsBoxForStore(String storeId) => '${productsTable}_$storeId';
}