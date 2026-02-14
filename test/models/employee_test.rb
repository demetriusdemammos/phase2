require "test_helper"

describe Employee do
  should have_many(:assignments)
  should have_many(:stores).through(:assignments)

  def valid_attrs
    {
      first_name: "Demetrius",
      last_name: "DeMammos",
      ssn: "103-76-8000",
      date_of_birth: Date.new(2005, 5, 5),
      phone: "2028179590",
      role: :manager,
      active: true
    }
  end

  before do
    # Active store needed for assignment tests (Assignment requires store to be active)
    @store = Store.create!(
      name: "CMU",
      street: "5000 Forbes Ave",
      city: "Pittsburgh",
      state: "PA",
      zip: "15213",
      phone: "4122683259",
      active: true
    )
    @jason = Employee.create!(
      first_name: "Jason",
      last_name: "Stevens",
      ssn: "103-76-8902",
      date_of_birth: 18.years.ago.to_date,
      phone: "412-268-3259",
      role: :employee,
      active: true
    )
    @amy = Employee.create!(
      first_name: "Amy",
      last_name: "Stevens",
      ssn: "103-76-8901",
      date_of_birth: 18.years.ago.to_date + 1.day,
      phone: "412-268-2000",
      role: :manager,
      active: true
    )
    @bob = Employee.create!(
      first_name: "Bob",
      last_name: "Apple",
      ssn: "105-76-8901",
      date_of_birth: Date.new(2000, 5, 10),
      phone: "412-268-1000",
      role: :admin,
      active: false
    )
  end 

  it "requires first name to be present" do
    employee = Employee.new(valid_attrs.merge(first_name: nil))
    _(employee.valid?).must_equal false
    _(employee.errors[:first_name]).wont_be_empty
  end

  it "requires last name to be present" do
    employee = Employee.new(valid_attrs.merge(last_name: nil))
    _(employee.valid?).must_equal false
    _(employee.errors[:last_name]).wont_be_empty
  end

  it "requires ssn to be present" do
    employee = Employee.new(valid_attrs.merge(ssn: nil))
    _(employee.valid?).must_equal false
    _(employee.errors[:ssn]).wont_be_empty
  end

  it "requires date_of_birth to be present" do
    employee = Employee.new(valid_attrs.merge(date_of_birth: nil))
    _(employee.valid?).must_equal false
    _(employee.errors[:date_of_birth]).wont_be_empty
  end

  it "requires phone to be present" do
    employee = Employee.new(valid_attrs.merge(phone: nil))
    _(employee.valid?).must_equal false
    _(employee.errors[:phone]).wont_be_empty
  end

  it "requires uniqueness of ssn" do
    employee = Employee.new(valid_attrs.merge(ssn: "105768901"))
    _(employee.valid?).must_equal false
    _(employee.errors[:ssn]).wont_be_empty
  end

  it "requires phone to be 10 digits" do
    employee = Employee.new(valid_attrs.merge(phone: "20281795"))
    _(employee.valid?).must_equal false
    _(employee.errors[:phone]).wont_be_empty
  end

  it "requires ssn to be 9 digits" do
    employee = Employee.new(valid_attrs.merge(ssn: "12345"))
    _(employee.valid?).must_equal false
    _(employee.errors[:ssn]).wont_be_empty
  end

  it "requires date_of_birth to be at least 14 years ago" do
    employee = Employee.new(valid_attrs.merge(date_of_birth: 10.years.ago.to_date))
    _(employee.valid?).must_equal false
    _(employee.errors[:date_of_birth]).wont_be_empty
  end

  it "accepts formatted phone and saves as 10 digits only" do
    employee = Employee.create!(valid_attrs.merge(first_name: "Phone", ssn: "111223333", phone: "(412) 268-3259"))
    _(employee.phone).must_equal "4122683259"
  end

  it "accepts formatted ssn and saves as 9 digits only" do
    employee = Employee.create!(valid_attrs.merge(first_name: "SSN", ssn: "103-76-9999", phone: "4122680000"))
    _(employee.ssn).must_equal "103769999"
  end

  # --- Instance methods: name, proper_name ---
  it "returns name as last_name, first_name" do
    _(@jason.name).must_equal "Stevens, Jason"
  end

  it "returns proper_name as first_name last_name" do
    _(@jason.proper_name).must_equal "Jason Stevens"
  end

  # --- current_assignment: need Store + Assignment ---
  it "returns nil when employee has no assignments" do
    _(@jason.current_assignment).must_be_nil
  end

  it "returns the current assignment when employee has one" do
    assignment = Assignment.create!(
      store: @store,
      employee: @jason,
      start_date: 1.week.ago.to_date,
      end_date: nil
    )
    _(@jason.current_assignment).must_equal assignment
  end

  it "returns nil when employee has only a past assignment" do
    Assignment.create!(
      store: @store,
      employee: @jason,
      start_date: 1.year.ago.to_date,
      end_date: 1.month.ago.to_date
    )
    _(@jason.current_assignment).must_be_nil
  end

  # --- over_18? ---
  it "returns true for employee 18 or older" do
    _(@jason.over_18?).must_equal true
    _(@bob.over_18?).must_equal true
  end

  it "returns false for employee under 18" do
    _(@amy.over_18?).must_equal false
  end

  # --- Role boolean methods ---
  it "has working manager_role?" do
    _(@amy.manager_role?).must_equal true
    _(@jason.manager_role?).must_equal false
  end

  it "has working employee_role?" do
    _(@jason.employee_role?).must_equal true
    _(@amy.employee_role?).must_equal false
  end

  it "has working admin_role?" do
    _(@bob.admin_role?).must_equal true
    _(@jason.admin_role?).must_equal false
  end

  # --- make_active / make_inactive ---
  it "make_inactive flips active to false and persists" do
    _(@jason.active).must_equal true
    @jason.make_inactive
    _(@jason.active).must_equal false
    @jason.reload
    _(@jason.active).must_equal false
  end

  it "make_active flips active to true and persists" do
    _(@bob.active).must_equal false
    @bob.make_active
    _(@bob.active).must_equal true
    @bob.reload
    _(@bob.active).must_equal true
  end






  ##############################
  ########SCOPE TESTS###########
  ##############################

  it "returns active employees" do
    _(Employee.active).must_include(@amy)
    _(Employee.active).must_include(@jason)
    _(Employee.active).wont_include(@bob)
  end

  it "returns inactive employees" do
    _(Employee.inactive).wont_include(@amy)
    _(Employee.inactive).wont_include(@jason)
    _(Employee.inactive).must_include(@bob)
  end

  it "returns employees alphabetically in lname,fname" do
    _(Employee.alphabetical.to_a).must_equal [@bob, @amy, @jason]
  end
  
  it "returns employees older than 18" do
    _(Employee.is_18_or_older).must_include(@jason)
    _(Employee.is_18_or_older).must_include(@bob)
    _(Employee.is_18_or_older).wont_include(@amy)
  end

  it "returns employees younger than 18" do
    _(Employee.younger_than_18).must_include(@amy)
    _(Employee.younger_than_18).wont_include(@jason)
    _(Employee.younger_than_18).wont_include(@bob)
  end

  it "returns regular employees" do
    _(Employee.regulars).must_include(@jason)
    _(Employee.regulars).wont_include(@amy)
    _(Employee.regulars).wont_include(@bob)
  end

  it "returns managers" do
    _(Employee.managers).must_include(@amy)
    _(Employee.managers).wont_include(@jason)
    _(Employee.managers).wont_include(@bob)
  end

  it "returns admins" do
    _(Employee.admins).must_include(@bob)
    _(Employee.admins).wont_include(@amy)
    _(Employee.admins).wont_include(@jason)
  end

  it "handles search correctly" do
    _(Employee.search("Amy")).must_include(@amy)
    _(Employee.search("Amy")).wont_include(@jason)
    _(Employee.search("Amy")).wont_include(@bob)
  end
end
