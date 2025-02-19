class Customer < ApplicationRecord
  has_many :orders
  has_many :addresses

  validates :first_name, presence: true
  validates :last_name, presence: true
  # validates :email, presence: true
  validates :phone, presence: true, format: { with: /\A\(?\d{3}\)?[.\-\s]?\d{3}[.\-\s]?\d{4}\z/, message: "must be a valid phone number format" }


  # # Strip non-digits before saving phone
  before_save :reformat_phone

  # Scopes
  scope :alphabetical, -> { order('last_name, first_name') }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # # Methods
  def name
    "#{last_name}, #{first_name}"
  end

  def proper_name
    "#{first_name} #{last_name}"
  end

  def make_active
    self.active = true
    save
  end

  def make_inactive
    self.active = false
    save
  end

  def billing_address
    addresses.find_by(address_type: "billing")
  end
  

  # private

  def reformat_phone
    phone = self.phone.to_s # Ensure it's a string
    phone.gsub!(/[^0-9]/, "") # Strip non-digit characters
    self.phone = phone       
  end
end

