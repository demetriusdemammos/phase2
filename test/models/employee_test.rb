require "test_helper"

describe Employee do
  should have_many(:assignments)
  should have_many(:stores).through(:assignments)

  before do
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
