FactoryBot.define do
  factory :address do
    recipient { "MyString" }
    street { "MyString" }
    city { "MyString" }
    state { "MyString" }
    zip { "MyString" }
    customer { nil }
    active { false }
    address_type { "MyString" }
  end
end
