FactoryBot.define do
  factory :customer do
    first_name { "MyString" }
    last_name { "MyString" }
    phone { "MyString" }
    active { false }
  end
end
