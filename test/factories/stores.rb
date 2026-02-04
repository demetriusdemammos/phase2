FactoryBot.define do
  factory :store do
    name { "Oakland" }
    street { "5000 Forbes Ave" }
    city { "Pittsburgh" }
    state { "PA" }
    zip { "15213" }
    phone { "412-268-3259" }
    active { true }
  end
end
