class MigrateCountryToCompany < ActiveRecord::Migration[6.0]
  def change
    ActsAsTenant.without_tenant do
      Company.all.update_all(country_id: Country.id_for('India'))
    end
  end
end
