class CreateGstConfigForAllCompanies < ActiveRecord::Migration[5.2]
  def change
    Company.all.each do |company|
      unless company.gst_config.present?

      end
    end
  end
end
