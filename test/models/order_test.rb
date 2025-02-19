require "test_helper"

describe Order do
  let(:customer) { Customer.create!(first_name: "John", last_name: "Doe", phone: "123-456-7890", active: true) }
  let(:address) { 
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

  # -----------------------
  # Tests for pay Method
  # -----------------------

  it "returns false if order is already paid" do
    order = Order.create!(customer: customer, address: address, order_date: Date.today, total: 100.00, payment_receipt: "Paid")
    result = order.pay
    _(result).must_equal false
  end

  it "returns false if billing address is missing" do
    no_billing_address = Address.create!(customer: customer, address_type: "shipping", recipient: "John Doe", street: "123 Main St", city: "Pittsburgh", state: "PA", zip: "15213", active: true)
    order = Order.create!(customer: customer, address: no_billing_address, order_date: Date.today, total: 100.00)
    
    result = order.pay
    _(result).must_equal false
  end

  it "returns false if update fails when saving the payment receipt" do
    order = Order.create!(customer: customer, address: address, order_date: Date.today, total: 100.00)
    
    # Stub update to simulate failure
    order.stub :update, false do
      result = order.pay
      _(result).must_equal false
    end
  end

  it "returns the receipt string if payment is successful" do
    order = Order.create!(customer: customer, address: address, order_date: Date.today, total: 100.00)
    result = order.pay

    expected_receipt = "order: #{order.id}; amount_paid: #{order.total}; received: #{order.order_date}; billing_zip: #{address.zip}"
    _(result).must_equal expected_receipt
    _(order.reload.payment_receipt).must_equal expected_receipt
  end
end
