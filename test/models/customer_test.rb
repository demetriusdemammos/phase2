require "test_helper"

describe Customer do
  let(:customer) { Customer.create!(first_name: "John", last_name: "Doe", phone: "123-456-7890", active: true) }
  let(:inactive_customer) { Customer.create!(first_name: "Jane", last_name: "Smith", phone: "987-654-3210", active: false) }

  # -----------------------
  # Validations
  # -----------------------
  it "validates presence of required fields" do
    invalid_customer = Customer.new
    _(invalid_customer.valid?).must_equal false
    _(invalid_customer.errors[:first_name]).wont_be_empty
    _(invalid_customer.errors[:last_name]).wont_be_empty
    _(invalid_customer.errors[:phone]).wont_be_empty
  end

  it "validates phone format" do
    customer.phone = "invalid"
    _(customer.valid?).must_equal false
    _(customer.errors[:phone]).must_include "must be a valid phone number format"
  end

  it "returns the customer's billing address" do
    billing = Address.create!(
      customer: customer, 
      address_type: "billing", 
      recipient: "John Doe",
      street: "123 Main St",
      city: "Pittsburgh",
      state: "PA",
      zip: "15213",
      active: true
    )

  
    _(customer.billing_address).must_equal billing

  end

  # -----------------------
  # Scopes
  # -----------------------
  it "returns customers in alphabetical order" do
    customer
    inactive_customer
    sorted = Customer.alphabetical.to_a
    _(sorted.map(&:last_name)).must_equal ["Doe", "Smith"]
  end
  

  it "returns active customers" do
    customer
    inactive_customer
    _(Customer.active).must_include customer
    _(Customer.active).wont_include inactive_customer
  end

  it "returns inactive customers" do
    customer
    inactive_customer
    _(Customer.inactive).must_include inactive_customer
    _(Customer.inactive).wont_include customer
  end

  # -----------------------
  # Instance Methods
  # -----------------------
  it "returns proper name" do
    _(customer.proper_name).must_equal "John Doe"
  end

  it "activates and deactivates customers" do
    inactive_customer.make_active
    _(inactive_customer.active).must_equal true

    customer.make_inactive
    _(customer.active).must_equal false
  end

  it "returns the customer's name in 'last, first' format" do
    _(customer.name).must_equal "Doe, John"
  end


  it "reformats phone numbers" do
    c = Customer.create!(first_name: "Tom", last_name: "Brown", phone: "(123) 456-7890")
    _(c.phone).must_equal "1234567890"
  end
end
