class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.string :recipient
      t.string :street
      t.string :city
      t.string :state
      t.string :zip
      t.references :customer, null: false, foreign_key: true
      t.boolean :active
      t.string :address_type

      t.timestamps
    end
  end
end
