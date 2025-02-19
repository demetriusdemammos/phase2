module Contexts
  module Orders
    def create_orders
      @order1 = Order.create(order_date: Date.today, total: 50.00, paid: true, customer: @customer1, address: @address1)
      @order2 = Order.create(order_date: Date.today - 1, total: 100.00, paid: false, customer: @customer2, address: @address2)
    end

    def destroy_orders
      @order1.destroy if @order1
      @order2.destroy if @order2
    end
  end
end
