FactoryBot.define do
  factory :order do
    customer { nil }
    address { nil }
    order_date { "2025-02-01" }
    total { "9.99" }
    paid { false }
    payment_receipt { "MyText" }
  end
end
