class AddSsoTypeToCompanySsoConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :single_sign_on_configurations, :single_sign_on_type_id, :integer, references: "SingleSignOnType", foreign_key: true, index: true
  end
end
