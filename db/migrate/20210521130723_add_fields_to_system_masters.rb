class AddFieldsToSystemMasters < ActiveRecord::Migration[6.0]

  def change
    add_column :categories, :field_1, :string, index: true
    add_column :categories, :field_2, :string, index: true
    add_column :categories, :field_3, :string, index: true
    add_column :categories, :field_4, :string, index: true
    add_column :categories, :field_5, :string, index: true

    add_column :cost_centers, :field_1, :string, index: true
    add_column :cost_centers, :field_2, :string, index: true
    add_column :cost_centers, :field_3, :string, index: true
    add_column :cost_centers, :field_4, :string, index: true
    add_column :cost_centers, :field_5, :string, index: true

    add_column :departments, :field_1, :string, index: true
    add_column :departments, :field_2, :string, index: true
    add_column :departments, :field_3, :string, index: true
    add_column :departments, :field_4, :string, index: true
    add_column :departments, :field_5, :string, index: true

    add_column :items, :field_1, :string, index: true
    add_column :items, :field_2, :string, index: true
    add_column :items, :field_3, :string, index: true
    add_column :items, :field_4, :string, index: true
    add_column :items, :field_5, :string, index: true

    add_column :branch_locations, :field_1, :string, index: true
    add_column :branch_locations, :field_2, :string, index: true
    add_column :branch_locations, :field_3, :string, index: true
    add_column :branch_locations, :field_4, :string, index: true
    add_column :branch_locations, :field_5, :string, index: true

    add_column :payment_terms, :field_1, :string, index: true
    add_column :payment_terms, :field_2, :string, index: true
    add_column :payment_terms, :field_3, :string, index: true
    add_column :payment_terms, :field_4, :string, index: true
    add_column :payment_terms, :field_5, :string, index: true

    add_column :states, :field_1, :string, index: true
    add_column :states, :field_2, :string, index: true
    add_column :states, :field_3, :string, index: true
    add_column :states, :field_4, :string, index: true
    add_column :states, :field_5, :string, index: true
  end
end
