class Address < ApplicationRecord
  belongs_to :customer
  has_many :orders

  # Validations
  validates :recipient, presence: true
  validates :street, presence: true
  validates :zip, presence: true, format: { with: /\A\d{5}\z/, message: "must be a 5-digit number" }
  validates :state, presence: true, inclusion: { in: %w(PA WV), message: "must be PA or WV" }
  validates :customer_id, presence: true
  validate :customer_must_exist_and_be_active
  validate :one_billing_address_per_customer


  validate :check_duplicate_address, on: :create

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_recipient, -> { order(:recipient) }
  scope :by_customer, -> { joins(:customer).order('customers.last_name, customers.first_name') }
  scope :shipping, -> { where(address_type: 'shipping') }
  scope :billing, -> { where(address_type: 'billing') }

  around_save :handle_billing_address_uniqueness, if: :billing_address_created?

  

  # Instance Methods

  # Check if address already exists (same recipient and zip for customer)
  def already_exists?
    Address.exists?(customer_id: customer_id, recipient: recipient, zip: zip)
  end

  # Make address active
  def make_active
    update(active: true)
  end

  # Make address inactive
  def make_inactive
    update(active: false)
  end

  private

  # Custom Validations
  # 
  


  # Ensure customer exists and is active
  def customer_must_exist_and_be_active
    unless customer&.active?
      errors.add(:customer_id, "must belong to an active customer")
    end
  end

  # Ensure there is only one billing address per customer
  def one_billing_address_per_customer
    return unless address_type == 'billing'
  
    existing_billing = customer.addresses.billing.where.not(id: id).first
    if existing_billing && will_save_change_to_attribute?(:address_type)
      errors.add(:address_type, "customer can only have one billing address")
    end
  end
  

  # Check for duplicate address (same recipient and zip for the same customer)
  def check_duplicate_address
    if already_exists?
      errors.add(:base, "This address already exists for the customer")
    end
  end


  # Check if the current address is a new billing address
  def billing_address_created?
    address_type == 'billing' && persisted?
  end

  private
  
  def handle_billing_address_uniqueness
    ActiveRecord::Base.transaction do
      convert_previous_billing_to_shipping
      yield # Proceed with saving after conversion
    end
  end
  
  def convert_previous_billing_to_shipping
    old_billing = customer.addresses.billing.where.not(id: id).first
    old_billing.update!(address_type: 'shipping') if old_billing.present?
  end
end
