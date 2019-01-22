class AddMoreDetailsToCollectCompanyDetail < ActiveRecord::Migration[4.2]
  def change
    add_column :collect_company_details, :address, :text
    add_column :collect_company_details, :pin, :text
  end
end
