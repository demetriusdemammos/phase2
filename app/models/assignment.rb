class Assignment < ApplicationRecord
  belongs_to :store
  belongs_to :employee

  # Validations
  validates_presence_of :start_date, :store_id, :employee_id
  validate :start_date_must_be_on_or_before_today
  validate :end_date_must_be_after_start_date
  validate :store_must_be_active
  validate :employee_must_be_active

  # Scopes
  scope :current, -> { where("start_date <= ?", Date.current).where("end_date IS NULL OR end_date >= ?", Date.current) }
  scope :past, -> { where("end_date IS NOT NULL AND end_date < ?", Date.current) }
  scope :by_store, -> { joins(:store).order("stores.name") }
  scope :by_employee, -> { joins(:employee).order("employees.last_name, employees.first_name") }
  scope :chronological, -> { order(start_date: :desc) }
  scope :for_store, ->(store) { where(store_id: store.id) }
  scope :for_employee, ->(employee) { where(employee_id: employee.id) }
  scope :for_role, ->(role) { joins(:employee).where(employees: { role: Employee.roles[role] }) }
  scope :for_date, ->(date) { where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", date, date) }

  # End the employee's current assignment when a new one is created
  before_create :end_current_assignment

  private

  def start_date_must_be_on_or_before_today
    return if start_date.blank?
    date_to_check = start_date.respond_to?(:to_date) ? start_date.to_date : start_date
    errors.add(:start_date, "must be on or before the present date") if date_to_check > Date.current
  end

  def end_date_must_be_after_start_date
    return if end_date.blank? || start_date.blank?
    errors.add(:end_date, "must be after start date") if end_date <= start_date
  end

  def store_must_be_active
    return if store_id.blank?
    return if Store.active.exists?(id: store_id)
    errors.add(:store_id, "must be an active store")
  end

  def employee_must_be_active
    return if employee_id.blank?
    return if Employee.active.exists?(id: employee_id)
    errors.add(:employee_id, "must be an active employee")
  end

  def end_current_assignment
    previous = employee.assignments.where(end_date: nil).where.not(id: id).take
    previous.update_column(:end_date, start_date) unless previous.nil?
  end
end
