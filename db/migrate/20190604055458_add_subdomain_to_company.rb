class AddSubdomainToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :subdomain, :string, index: true
  end
end
