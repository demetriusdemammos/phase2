class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.date :order_date
      t.decimal :total
      t.boolean :paid
      t.text :payment_receipt

      t.timestamps
    end
  end
end
