class MigrateCompanyNameToLegalEntityName < ActiveRecord::Migration[5.2]
  def change
    Company.all.includes(:configuration).each do |company|
      configuration = company.configuration
      configuration.update_columns(legal_entity_name: company.name)
    end
  end
end
