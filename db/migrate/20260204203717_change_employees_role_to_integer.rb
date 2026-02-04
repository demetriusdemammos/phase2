class ChangeEmployeesRoleToInteger < ActiveRecord::Migration[8.1]
  def up
    add_column :employees, :role_int, :integer, default: 1, null: false

    execute <<~SQL
      UPDATE employees
      SET role_int = CASE
        WHEN role = 'manager' THEN 2
        WHEN role = 'admin' THEN 3
        ELSE 1
      END
    SQL

    remove_column :employees, :role
    rename_column :employees, :role_int, :role
  end

  def down
    add_column :employees, :role_str, :string

    execute <<~SQL
      UPDATE employees
      SET role_str = CASE role
        WHEN 2 THEN 'manager'
        WHEN 3 THEN 'admin'
        ELSE 'employee'
      END
    SQL

    remove_column :employees, :role
    rename_column :employees, :role_str, :role
  end
end
