/// Model Vendor / Agen / Supplier
class Vendor {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final List<String> suppliedCategories;

  Vendor({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.suppliedCategories = const [],
  });
}