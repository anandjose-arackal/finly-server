# == Schema Information
#
# Table name: pin_code_city_id_mappings
#
#  id         :integer          not null, primary key
#  pin_code   :string(255)
#  city_id    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PinCodeCityIdMapping < ActiveRecord::Base

  scope :with_pin_code, -> (pin_code) {where pin_code: pin_code}
  scope :with_city_id, -> (city_id) {where city_id: city_id}

  def self.seed_data
    file = File.open('./pincode_mst.csv')
    sheet = Roo::CSV.new(file.path)
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      pin_code = row[1]
      city_id = row[2]
      unless PinCodeCityIdMapping.with_pin_code(pin_code).with_city_id(city_id).present?
        PinCodeCityIdMapping.create(pin_code: pin_code, city_id: city_id)
      end
    end
  end
end
