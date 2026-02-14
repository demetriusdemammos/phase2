class Employee < ApplicationRecord
  has_many :assignments
  has_many :stores, through: :assignments

  enum :role, { employee: 1, manager: 2, admin: 3 }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :alphabetical, -> { order(:last_name, :first_name) }
  scope :is_18_or_older, -> { where("date_of_birth <= ?", 18.years.ago.to_date) }
  scope :younger_than_18, -> { where("date_of_birth > ?", 18.years.ago.to_date) }
  scope :regulars, -> { where(role: roles[:employee]) }
  scope :managers, -> { where(role: roles[:manager]) }
  scope :admins, -> { where(role: roles[:admin]) }
  scope :search, ->(term) { where("first_name LIKE ? OR last_name LIKE ?", "#{term}%", "#{term}%") }

  def manager_role?
    manager?
  end

  def employee_role?
    employee? 
  end

  def admin_role?
    admin?
  end

  validates_presence_of :first_name, :last_name, :ssn, :date_of_birth, :phone
  validates_uniqueness_of :ssn
  validate :phone_must_be_10_digits
  validate :ssn_must_be_9_digits
  validate :date_of_birth_must_be_at_least_14

  before_save :normalize_phone, :normalize_ssn
  
  def name
    "#{last_name}, #{first_name}"
  end

  def proper_name
    "#{first_name} #{last_name}"
  end

  def current_assignment
    assignments.where("start_date <= ?", Date.current).where("end_date IS NULL OR end_date >= ?", Date.current).order(start_date: :desc).first
  end

  def over_18?
    date_of_birth <= 18.years.ago.to_date
  end

  def make_active
    update!(active: true)
  end

  def make_inactive
    update!(active: false)
  end

  private

  def normalize_phone
    return if phone.blank?
    self.phone = phone.to_s.gsub(/\D/, "").strip
  end

  def normalize_ssn
    return if ssn.blank?
    self.ssn = ssn.to_s.gsub(/\D/, "").strip
  end

  def phone_must_be_10_digits
    return if phone.blank?
    digits_only = phone.to_s.gsub(/\D/, "")
    errors.add(:phone, "must be 10 digits") unless digits_only.length == 10
  end

  def ssn_must_be_9_digits
    return if ssn.blank?
    digits_only = ssn.to_s.gsub(/\D/, "")
    errors.add(:ssn, "must be 9 digits") unless digits_only.length == 9
  end

  def date_of_birth_must_be_at_least_14
    return if date_of_birth.blank?
    errors.add(:date_of_birth, "must be at least 14 years ago") if date_of_birth > 14.years.ago.to_date
  end
end
