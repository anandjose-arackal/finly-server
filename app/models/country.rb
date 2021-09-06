# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#
class Country < NonTenantedApplicationRecord

  def self.id_for(country)
    find_by(name: country)&.id
  end

  def self.ids_for(countries)
    where(name: countries).pluck(:id)
  end

end


