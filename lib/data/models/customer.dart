/// Model Customer / Pelanggan
class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? address;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
  });
}
