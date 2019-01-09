class SeedCustomExportConfigurationsForAllCompanies < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      company.build_custom_export_configuration(custom_report: false, custom_invoice: false, custom_purchase_order: false).save
    end
  end
end
