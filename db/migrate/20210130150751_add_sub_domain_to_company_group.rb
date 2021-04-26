class AddSubDomainToCompanyGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :company_groups, :subdomain, :string
  end
end
