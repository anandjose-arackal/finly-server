class AddShowCustomFieldsInPdfToCompanyConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :company_configurations, :show_custom_fields_in_pdf, :boolean, default: true
  end
end
