import '../models/customer.dart';
import '../repositories/customer_repository.dart';

class DummyCustomerRepository implements CustomerRepository {
  final List<Customer> _customers = [
    Customer(id: 'c001', name: 'Bu Sari', phone: '0812-1111-2222'),
    Customer(id: 'c002', name: 'Pak Budi', phone: '0813-3333-4444'),
    Customer(id: 'c003', name: 'Mbak Rina', phone: '0821-5555-6666'),
  ];

  @override
  Future<List<Customer>> getAllCustomers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_customers);
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    _customers.add(customer);
  }
}