class RemoveOcrEnabledInCompanyConfiguration < ActiveRecord::Migration
  def change
    remove_column :company_configurations, :ocr_enabled
  end
end
