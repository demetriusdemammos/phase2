class Store < ApplicationRecord
  has_many :assignments
  has_many :employees, through: :assignments

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :alphabetical, -> { order(:name) }
end
 