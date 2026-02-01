class Store < ApplicationRecord
  has_many :assignments
  has_many :employees, through: :assignments

  before_validation :reformat_phone

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :street, presence: true
  validates :city, presence: true
  validates :state, presence: true, inclusion: { in: %w[PA OH WV] }
  validates :zip, presence: true, format: { with: /\A\d{5}\z/ }
  validates :phone, presence: true, format: { with: /\A\d{10}\z/ }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :alphabetical, -> { order(:name) }

  def make_active
    update(active: true)
  end

  def make_inactive
    update(active: false)
  end

  private

  def reformat_phone
    return if phone.blank?

    self.phone = phone.to_s.gsub(/\D/, "")
  end
end
