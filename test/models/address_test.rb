require "test_helper"

describe Address do
  let(:customer) { Customer.create!(first_name: "John", last_name: "Doe", phone: "123-456-7890", active: true) }
  let(:billing_address) {
    Address.create!(
      customer: customer,
      address_type: "billing",
      recipient: "John Doe",
      street: "123 Main St",
      city: "Pittsburgh",
      state: "PA",
      zip: "15213",
      active: true
    )
  } 
  let(:shipping_address) {
    Address.create!(
      customer: customer,
      address_type: "shipping",
      recipient: "Jane Doe",
      street: "456 Second St",
      city: "Pittsburgh",
      state: "PA",
      zip: "15214",
      active: true
    )
  }

  # -----------------------
  # Validations
  # -----------------------
  it "validates presence of all fields" do
    invalid_address = Address.new
    _(invalid_address.valid?).must_equal false
    %i[recipient street zip state customer_id].each do |field|
      _(invalid_address.errors[field]).wont_be_empty
    end
  end

  it "validates zip format and state inclusion" do
    address = Address.new(zip: "123", state: "NY")
    address.valid?
    _(address.errors[:zip]).must_include "must be a 5-digit number"
    _(address.errors[:state]).must_include "must be PA or WV"
  end

  it "validates only one billing address per customer" do
    billing_address
    second_billing = Address.new(customer: customer, address_type: "billing", recipient: "New Bill")
    _(second_billing.valid?).must_equal false
    _(second_billing.errors[:address_type]).must_include "customer can only have one billing address"
  end

  it "validates customer must be active" do
    inactive_customer = Customer.create!(first_name: "Jane", last_name: "Smith", phone: "987-654-3210", active: false)
    address = Address.new(customer: inactive_customer, address_type: "billing", recipient: "Jane Smith")
    address.valid?
    _(address.errors[:customer_id]).must_include "must belong to an active customer"
  end

  it "validates duplicate addresses" do
    billing_address
    duplicate = Address.new(customer: customer, recipient: "John Doe", zip: "15213")
    _(duplicate.valid?).must_equal false
    _(duplicate.errors[:base]).must_include "This address already exists for the customer"
  end
  

  # -----------------------
  # Scopes
  # -----------------------
  it "returns addresses correctly via scopes" do
    billing_address
    shipping_address

    _(Address.active).must_include billing_address
    _(Address.inactive).must_be_empty
    _(Address.billing).must_include billing_address
    _(Address.shipping).must_include shipping_address
    _(Address.by_recipient.first).must_equal shipping_address
    _(Address.by_customer.first).must_equal billing_address
  end



  it "checks if an address already exists" do
    billing_address
    duplicate = Address.new(customer: customer, recipient: "John Doe", zip: "15213")
    _(duplicate.already_exists?).must_equal true
  end

  it "makes address active and inactive" do
    shipping_address.make_inactive
    _(shipping_address.reload.active).must_equal false

    shipping_address.make_active
    _(shipping_address.reload.active).must_equal true
  end
end
