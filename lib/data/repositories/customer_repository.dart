import '../models/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAllCustomers();
  Future<void> addCustomer(Customer customer);
}