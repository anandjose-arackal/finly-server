class AddMoreDetailsToCollectCompanyDetail < ActiveRecord::Migration
  def change
    add_column :collect_company_details, :address, :text
    add_column :collect_company_details, :pin, :text
  end
end
