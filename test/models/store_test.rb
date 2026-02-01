require "test_helper"

describe Store do
  before do
    @oakland = Store.create!(
      name: "Oakland",
      street: "5000 Forbes Ave",
      city: "Pittsburgh",
      state: "PA",
      zip: "15213",
      phone: "412-268-3259",
      active: true
    )
    @morewood = Store.create!(
      name: "Morewood",
      street: "3000 Morewood Ave",
      city: "Pittsburgh",
      state: "PA",
      zip: "15213",
      phone: "412.268.1111",
      active: false
    )
  end

  it "returns active stores" do
    _(Store.active).must_include @oakland
    _(Store.active).wont_include @morewood
  end

  it "returns inactive stores" do
    _(Store.inactive).must_include @morewood
    _(Store.inactive).wont_include @oakland
  end

  it "orders stores alphabetically" do
    _(Store.alphabetical.to_a).must_equal [@morewood, @oakland]
  end
end
