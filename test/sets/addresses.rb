module Contexts
  module Addresses
    def create_addresses
      @address1 = Address.create(street: "123 Main St", city: "Pittsburgh", state: "PA", zip: "15213", customer: @customer1, active: true)
      @address2 = Address.create(street: "456 Elm St", city: "Philadelphia", state: "PA", zip: "19103", customer: @customer2, active: false)
    end

    def destroy_addresses
      @address1.destroy if @address1
      @address2.destroy if @address2
    end
  end
end
