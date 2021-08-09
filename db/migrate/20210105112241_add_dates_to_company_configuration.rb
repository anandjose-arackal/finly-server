class AddDatesToCompanyConfiguration < ActiveRecord::Migration[6.0]
  def change
    add_column :company_configurations, :start_date, :date
    add_column :company_configurations, :end_date, :date
  end
end
