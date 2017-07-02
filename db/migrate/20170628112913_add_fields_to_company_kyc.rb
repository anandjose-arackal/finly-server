class AddFieldsToCompanyKyc < ActiveRecord::Migration
  def change
    drop_attached_file :company_kycs, :agreement

    add_column :company_kycs, :customer_type_name, :string
    add_column :company_kycs, :date_of_establishment, :date
    add_column :company_kycs, :street_2, :text
    add_column :company_kycs, :street_3, :text
    add_column :company_kycs, :registered_mobile_number, :string
    add_column :company_kycs, :pan_card_no, :string
    add_column :company_kycs, :pin_code, :string
    add_column :company_kycs, :city_code, :string
  end
end
