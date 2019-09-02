class AddLegalEntityNameToCompanyConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :company_configurations, :legal_entity_name, :string
  end
end
