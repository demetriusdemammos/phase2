class RenameEmployeeSsn < ActiveRecord::Migration[8.1]
  def change
    rename_column :employees, :SSN, :ssn
  end
end
