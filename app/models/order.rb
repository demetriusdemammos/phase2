class Order < ApplicationRecord
  belongs_to :customer
  belongs_to :address

  # Validations
  validates :customer_id, presence: true
  validates :address_id, presence: true
  validates :order_date, presence: true
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :customer_must_exist_and_be_active
  validate :address_must_exist_and_be_active

  #rewrite the above two lines with something like
  #validates_presence_of :customer
  #validates active :true

  # Scopes
  scope :chronological, -> { order(order_date: :desc) }
  scope :paid, -> { where.not(payment_receipt: [nil, ""]) }
  scope :for_customer, ->(customer_id) { where(customer_id: customer_id) }

  # Instance Methods

  # Generates a payment receipt string if not already paid
  def pay
    return false if payment_receipt.present? # Prevent double-payments

    billing_zip = customer.addresses.billing.first&.zip
    return false if billing_zip.nil?

    # Create receipt string (no encoding)
    receipt_string = "order: #{id}; amount_paid: #{total}; received: #{order_date}; billing_zip: #{billing_zip}"

    # Save the receipt and return the string
    if update(payment_receipt: receipt_string)
      receipt_string
    else
      false
    end
  end

  private

  # Custom Validations

  # Ensure customer exists and is active
  def customer_must_exist_and_be_active
    customer&.active?

  end

  # Ensure address exists and is active
  def address_must_exist_and_be_active
    address&.active?

  end
end
