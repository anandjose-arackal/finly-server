class RemoveOcrEnabledInCompanyConfiguration < ActiveRecord::Migration[4.2]
  def change
    remove_column :company_configurations, :ocr_enabled
  end
end
