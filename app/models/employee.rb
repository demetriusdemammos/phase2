class Employee < ApplicationRecord
  has_many :assignments
  has_many :stores, through: :assignments

  enum role: { employee: 1, manager: 2, admin: 3 }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :alphabetical, -> { order(:last_name, :first_name) }
  scope :is_18_or_older, -> { where("date_of_birth <= ?", 18.years.ago.to_date) }
  scope :younger_than_18, -> { where("date_of_birth > ?", 18.years.ago.to_date) }
  scope :regulars, -> { where(role: roles[:employee]) }
  scope :managers, -> { where(role: roles[:manager]) }
  scope :admins, -> { where(role: roles[:admin]) }
  scope :search, ->(term) { where("first_name LIKE ? OR last_name LIKE ?", "#{term}%", "#{term}%") }
end
