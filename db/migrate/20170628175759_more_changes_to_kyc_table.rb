class MoreChangesToKycTable < ActiveRecord::Migration
  def change
    remove_column :company_kycs, :customer_type_name, :string

    create_table :company_types do |t|
      t.name

      t.timestamps null: false
    end

    add_column :company_kycs, :company_type_id, :integer
  end
end
