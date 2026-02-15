class Store < ApplicationRecord
  has_many :assignments 
  has_many :employees, through: :assignments

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :alphabetical, -> { order(:name) }


  validates_presence_of :name, :street, :city, :state, :zip, :phone
  validates_uniqueness_of :name, case_sensitive: false
  validates_inclusion_of :state, in: %w[PA OH WV], message: "is not an option"
  validates_format_of :zip, with: /\A\d{5}\z/, message: "should be five digits long"
  validate :phone_must_be_10_digits


  before_save :normalize_phone

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

  def phone_must_be_10_digits
    return if phone.blank?
    digits_only = phone.to_s.gsub(/\D/, "")
    errors.add(:phone, "must be 10 digits") unless digits_only.length == 10
  end
end 