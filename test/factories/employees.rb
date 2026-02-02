FactoryBot.define do
  factory :employee do
    first_name { "MyString" }
    last_name { "MyString" }
    SSN { "MyString" }
    date_of_birth { "2026-02-01" }
    phone { "MyString" }
    role { "MyString" }
    active { false }
  end
end
