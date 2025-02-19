# Require needed files for context setups
require_relative './sets/customers'
require_relative './sets/addresses'
require_relative './sets/orders'

module Contexts
  # Explicitly include all sets of contexts used for testing
  include Contexts::Customers
  include Contexts::Addresses
  include Contexts::Orders

  def create_all
    puts "Building context..."
    create_customers
    puts "Built customers"
    create_addresses
    puts "Built addresses"
    create_orders
    puts "Built orders"
  end

  def destroy_all
    puts "Destroying context..."
    destroy_orders
    puts "Destroyed orders"
    destroy_addresses
    puts "Destroyed addresses"
    destroy_customers
    puts "Destroyed customers"
  end
end
