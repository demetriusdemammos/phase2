module Contexts
  module Customers
    def create_customers
      @customer1 = Customer.create(first_name: "John", last_name: "Doe", email: "john.doe@example.com", phone: "1234567890", active: true)
      @customer2 = Customer.create(first_name: "Jane", last_name: "Smith", email: "jane.smith@example.com", phone: "9876543210", active: false)
    end

    def destroy_customers
      @customer1.destroy if @customer1
      @customer2.destroy if @customer2
    end
  end
end