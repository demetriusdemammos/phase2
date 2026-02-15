require "test_helper"

describe Assignment do
  should belong_to(:store)
  should belong_to(:employee)

  def valid_attrs
    {
      store: @store,
      employee: @jason,
      start_date: 1.week.ago.to_date,
      end_date: nil
    }
  end

  before do
    @store = Store.create!(
      name: "Oakland",
      street: "5000 Forbes Ave",
      city: "Pittsburgh",
      state: "PA",
      zip: "15213",
      phone: "4122683259",
      active: true
    )
    @store_b = Store.create!(
      name: "Morewood",
      street: "3000 Morewood Ave",
      city: "Pittsburgh",
      state: "PA",
      zip: "15214",
      phone: "4122681111",
      active: true
    )
    @inactive_store = Store.create!(
      name: "Inactive",
      street: "1000 Inactive St",
      city: "Pittsburgh",
      state: "PA",
      zip: "15215",
      phone: "4122680000",
      active: false
    )
    @jason = Employee.create!(
      first_name: "Jason",
      last_name: "Stevens",
      ssn: "103768902",
      date_of_birth: 18.years.ago.to_date,
      phone: "4122683259",
      role: :employee,
      active: true
    )
    @amy = Employee.create!(
      first_name: "Amy",
      last_name: "Apple",
      ssn: "103768901",
      date_of_birth: 18.years.ago.to_date,
      phone: "4122682000",
      role: :manager,
      active: true
    )
    @bob = Employee.create!(
      first_name: "Bob",
      last_name: "Zebra",
      ssn: "105768901",
      date_of_birth: Date.new(2000, 5, 10),
      phone: "4122681000",
      role: :admin,
      active: false
    )
  end

  # --- Validations ---
  describe "validations" do
    it "requires start_date to be present" do
      assignment = Assignment.new(valid_attrs.merge(start_date: nil))
      _(assignment.valid?).must_equal false
      _(assignment.errors[:start_date]).wont_be_empty
    end

    it "requires store_id to be present" do
      assignment = Assignment.new(valid_attrs.merge(store: nil))
      _(assignment.valid?).must_equal false
      _(assignment.errors[:store_id]).wont_be_empty
    end

    it "requires employee_id to be present" do
      assignment = Assignment.new(valid_attrs.merge(employee: nil))
      _(assignment.valid?).must_equal false
      _(assignment.errors[:employee_id]).wont_be_empty
    end

    it "requires start_date to be on or before today" do
      assignment = Assignment.new(valid_attrs.merge(start_date: 1.day.from_now.to_date))
      _(assignment.valid?).must_equal false
      _(assignment.errors[:start_date]).wont_be_empty
    end

    it "accepts start_date on or before today" do
      assignment = Assignment.new(valid_attrs.merge(start_date: Date.current))
      _(assignment.valid?).must_equal true
    end

    it "requires end_date to be after start_date when present" do
      assignment = Assignment.new(
        valid_attrs.merge(
          start_date: 1.week.ago.to_date,
          end_date: 2.weeks.ago.to_date
        )
      )
      _(assignment.valid?).must_equal false
      _(assignment.errors[:end_date]).wont_be_empty
    end

    it "rejects end_date equal to start_date" do
      d = 1.week.ago.to_date
      assignment = Assignment.new(valid_attrs.merge(start_date: d, end_date: d))
      _(assignment.valid?).must_equal false
      _(assignment.errors[:end_date]).wont_be_empty
    end

    it "accepts valid end_date after start_date" do
      assignment = Assignment.new(
        valid_attrs.merge(
          start_date: 1.month.ago.to_date,
          end_date: 1.week.ago.to_date
        )
      )
      _(assignment.valid?).must_equal true
    end

    it "requires store to be active" do
      assignment = Assignment.new(valid_attrs.merge(store: @inactive_store))
      _(assignment.valid?).must_equal false
      _(assignment.errors[:store_id]).wont_be_empty
    end

    it "requires employee to be active" do
      assignment = Assignment.new(valid_attrs.merge(employee: @bob))
      _(assignment.valid?).must_equal false
      _(assignment.errors[:employee_id]).wont_be_empty
    end
  end

  # --- Scopes ---
  describe "scopes" do
    before do
      @current_assign = Assignment.create!(
        store: @store,
        employee: @jason,
        start_date: 1.week.ago.to_date,
        end_date: nil
      )
      @past_assign = Assignment.create!(
        store: @store_b,
        employee: @amy,
        start_date: 1.year.ago.to_date,
        end_date: 1.month.ago.to_date
      )
    end

    it "current returns only current assignments" do
      _(Assignment.current).must_include @current_assign
      _(Assignment.current).wont_include @past_assign
    end

    it "past returns only terminated assignments" do
      _(Assignment.past).must_include @past_assign
      _(Assignment.past).wont_include @current_assign
    end

    it "by_store orders by store name" do
      result = Assignment.by_store.to_a
      _(result.map(&:store).map(&:name)).must_equal ["Morewood", "Oakland"]
    end

    it "by_employee orders by employee last name, first name" do
      result = Assignment.by_employee.to_a
      _(result.map { |a| [a.employee.last_name, a.employee.first_name] }).must_equal [["Apple", "Amy"], ["Stevens", "Jason"]]
    end

    it "chronological orders with most recent start_date first" do
      result = Assignment.chronological.to_a
      _(result.first).must_equal @current_assign
      _(result.last).must_equal @past_assign
    end

    it "for_store returns assignments for given store" do
      _(Assignment.for_store(@store)).must_include @current_assign
      _(Assignment.for_store(@store)).wont_include @past_assign
      _(Assignment.for_store(@store_b)).must_include @past_assign
    end

    it "for_employee returns assignments for given employee" do
      _(Assignment.for_employee(@jason)).must_include @current_assign
      _(Assignment.for_employee(@jason)).wont_include @past_assign
      _(Assignment.for_employee(@amy)).must_include @past_assign
    end

    it "for_role returns assignments for employees with given role" do
      _(Assignment.for_role(:employee)).must_include @current_assign
      _(Assignment.for_role(:manager)).must_include @past_assign
    end

    it "for_date returns assignments active on that date" do
      # A date when @current_assign was active (start in past, no end)
      mid_week = 3.days.ago.to_date
      _(Assignment.for_date(mid_week)).must_include @current_assign
      _(Assignment.for_date(mid_week)).wont_include @past_assign
      # A date when @past_assign was active
      past_date = 6.months.ago.to_date
      _(Assignment.for_date(past_date)).must_include @past_assign
    end
  end

  # --- Callback: end current assignment when new one created ---
  describe "callback" do
    it "ends employee current assignment when new assignment is created" do
      first = Assignment.create!(
        store: @store,
        employee: @jason,
        start_date: 1.month.ago.to_date,
        end_date: nil
      )
      _(first.end_date).must_be_nil

      Assignment.create!(
        store: @store,
        employee: @jason,
        start_date: 1.week.ago.to_date,
        end_date: nil
      )

      first.reload
      _(first.end_date).must_equal Date.current
    end
  end
end
