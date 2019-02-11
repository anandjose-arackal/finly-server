class AddOcrToCompanyConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :company_configurations, :ocr_enabled, :boolean
  end
end
