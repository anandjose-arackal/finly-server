class CityIdCityCodeMapping < ActiveRecord::Base

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
