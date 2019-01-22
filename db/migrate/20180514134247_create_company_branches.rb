class CreateCompanyBranches < ActiveRecord::Migration[4.2]
  def change
    create_table :company_branches do |t|
      t.references :collect_company_detail, index: true, foreign_key: true
      t.string :name
      t.text :address
      t.string :pan
      t.string :gst

      t.timestamps null: false
    end
  end
end
