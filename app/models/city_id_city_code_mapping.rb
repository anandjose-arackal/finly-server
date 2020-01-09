# == Schema Information
#
# Table name: city_id_city_code_mappings
#
#  id         :integer          not null, primary key
#  city_id    :string(255)
#  city_code  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CityIdCityCodeMapping < ApplicationRecord

  scope :with_city_id, -> (city_id) {where city_id: city_id}
  scope :with_city_code, -> (city_code) {where city_code: city_code}


  def self.seed_data
    file = File.open('./City.csv')
    sheet = Roo::CSV.new(file.path)
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      city_id = row[0]
      city_code = row[2]
      unless CityIdCityCodeMapping.with_city_id(city_id).with_city_code(city_code).present?
        CityIdCityCodeMapping.create(city_id: city_id, city_code: city_code)
      end
    end
  end
end
