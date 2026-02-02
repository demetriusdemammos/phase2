class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :SSN
      t.date :date_of_birth
      t.string :phone
      t.string :role
      t.boolean :active

      t.timestamps
    end
  end
end
