class AddStartDateAndEndDateToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_column :departments, :start_date, :date, index: true
    add_column :departments, :end_date, :date, index: true
    add_column :cost_centers, :start_date, :date, index: true
    add_column :cost_centers, :end_date, :date, index: true
    add_column :categories, :start_date, :date, index: true
    add_column :categories, :end_date, :date, index: true
    add_column :payment_terms, :start_date, :date, index: true
    add_column :payment_terms, :end_date, :date, index: true
    add_column :items, :start_date, :date, index: true
    add_column :items, :end_date, :date, index: true
    add_column :users, :start_date, :date, index: true
    add_column :users, :end_date, :date, index: true
  end
end
