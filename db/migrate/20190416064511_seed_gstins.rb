class SeedGstins < ActiveRecord::Migration[5.2]
  def change
    file_path = "#{Rails.root}/db/seeds/gstins.json"
    data = JSON.parse(File.read(file_path))

    total = data.length
    data.each_with_index do |gstin_master, index|
      gstin_json = ActiveSupport::HashWithIndifferentAccess.new gstin_master

      gstin = gstin_json[:gstin]

      if gstin.present?
        unless Gstin.with_gstin(gstin).present?
          if Gstin.new(gstin_json).save
            p "Seeding #{index + 1}/#{total}"
          end
        end
      end
    end
  end
end
