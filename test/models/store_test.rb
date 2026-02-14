require "test_helper"

describe Store do
  # --- Associations ---
  should have_many(:assignments) 
  should have_many(:employees).through(:assignments)

  # Valid store attributes for building new records (avoids duplicating valid data)
  def valid_attrs
    {
      name: "Test Store",
      street: "5000 Forbes Ave",
      city: "Pittsburgh",
      state: "PA",
      zip: "15213",
      phone: "4122683259",
      active: true
    }
  end
 
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

  # --- Validations: presence ---
  describe "validations" do
    it "requires name to be present" do
      store = Store.new(valid_attrs.merge(name: nil))
      _(store.valid?).must_equal false
      _(store.errors[:name]).wont_be_empty
    end

    it "requires street to be present" do
      store = Store.new(valid_attrs.merge(street: nil))
      _(store.valid?).must_equal false
      _(store.errors[:street]).wont_be_empty
    end

    it "requires city to be present" do
      store = Store.new(valid_attrs.merge(city: nil))
      _(store.valid?).must_equal false
      _(store.errors[:city]).wont_be_empty
    end

    it "requires state to be present" do
      store = Store.new(valid_attrs.merge(state: nil))
      _(store.valid?).must_equal false
      _(store.errors[:state]).wont_be_empty
    end

    it "requires zip to be present" do
      store = Store.new(valid_attrs.merge(zip: nil))
      _(store.valid?).must_equal false
      _(store.errors[:zip]).wont_be_empty
    end

    it "requires phone to be present" do
      store = Store.new(valid_attrs.merge(phone: nil))
      _(store.valid?).must_equal false
      _(store.errors[:phone]).wont_be_empty
    end

    it "requires name to be unique case-insensitively" do
      store = Store.new(valid_attrs.merge(name: "oakland", phone: "4122680000"))
      _(store.valid?).must_equal false
      _(store.errors[:name]).wont_be_empty
    end

    it "accepts valid name when unique" do
      store = Store.new(valid_attrs)
      _(store.valid?).must_equal true
    end

    it "requires state to be PA, OH, or WV" do
      store = Store.new(valid_attrs.merge(name: "Bad State", state: "NY"))
      _(store.valid?).must_equal false
      _(store.errors[:state]).wont_be_empty
    end

    it "accepts state PA, OH, or WV" do
      %w[PA OH WV].each do |state|
        store = Store.new(valid_attrs.merge(name: "Store #{state}", state: state))
        _(store.valid?).must_equal true
      end
    end

    it "requires zip to be exactly 5 digits" do
      store = Store.new(valid_attrs.merge(name: "Bad Zip", zip: "1234"))
      _(store.valid?).must_equal false
      _(store.errors[:zip]).wont_be_empty

      store.zip = "123456"
      _(store.valid?).must_equal false

      store.zip = "12a34"
      _(store.valid?).must_equal false
    end

    it "accepts valid 5-digit zip" do
      store = Store.new(valid_attrs.merge(zip: "15213"))
      _(store.valid?).must_equal true
    end

    it "requires phone to be 10 digits (allows formatted input)" do
      store = Store.new(valid_attrs.merge(name: "Formatted", phone: "412-268-3259"))
      _(store.valid?).must_equal true

      store.phone = "412"
      _(store.valid?).must_equal false
      _(store.errors[:phone]).wont_be_empty

      store.phone = "41226832590"
      _(store.valid?).must_equal false
    end

    it "accepts phone with parentheses and spaces" do
      store = Store.new(valid_attrs.merge(name: "Parens", phone: "(412) 268-3259"))
      _(store.valid?).must_equal true
    end
  end

  # --- Phone normalization ---
  describe "phone normalization" do
    it "saves phone as 10 digits only when given dashes" do
      store = Store.create!(valid_attrs.merge(name: "Dash", phone: "412-268-3259"))
      _(store.phone).must_equal "4122683259"
    end

    it "saves phone as 10 digits only when given parentheses" do
      store = Store.create!(valid_attrs.merge(name: "Paren", phone: "(412) 268-3259"))
      _(store.phone).must_equal "4122683259"
    end

    it "saves phone as 10 digits only when given dots" do
      store = Store.create!(valid_attrs.merge(name: "Dot", phone: "412.268.3259"))
      _(store.phone).must_equal "4122683259"
    end
  end

  # --- Scopes ---
  describe "scopes" do
    it "returns only active stores" do
      _(Store.active).must_include @oakland
      _(Store.active).wont_include @morewood
    end

    it "returns only inactive stores" do
      _(Store.inactive).must_include @morewood
      _(Store.inactive).wont_include @oakland
    end

    it "orders stores alphabetically by name" do
      _(Store.alphabetical.to_a).must_equal [@morewood, @oakland]
    end
  end

  # --- Instance methods ---
  describe "#make_active" do
    it "flips active from false to true and persists" do
      _(@morewood.active).must_equal false
      @morewood.make_active
      _(@morewood.active).must_equal true
      @morewood.reload
      _(@morewood.active).must_equal true
    end
  end

  describe "#make_inactive" do
    it "flips active from true to false and persists" do
      _(@oakland.active).must_equal true
      @oakland.make_inactive
      _(@oakland.active).must_equal false
      @oakland.reload
      _(@oakland.active).must_equal false
    end
  end
end
