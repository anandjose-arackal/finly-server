class AddOcrToCompanyConfiguration < ActiveRecord::Migration
  def change
    add_column :company_configurations, :ocr_enabled, :boolean
  end
end
