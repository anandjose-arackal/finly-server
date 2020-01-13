class CreateOlapDimensionsCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :olap_dimensions_companies do |t|
      t.olap_references

      t.string :name, index: true
      t.boolean :active, index: true
      t.integer :base_currency_id, index: true
      t.string :status, index: true
      t.boolean :test_account, index: true
      t.string :subdomain, index: true
      t.integer :group_id, index: true

      t.timestamps index: true
    end
  end
end
