class CreateCollectCompanyDetails < ActiveRecord::Migration
  def change
    create_table :collect_company_details do |t|
      t.string :gst
      t.string :pan
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end

    Company.all.each do |company|
      company.build_collect_company_detail.save
    end
  end
end
