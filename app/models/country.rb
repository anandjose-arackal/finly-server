class Country < NonTenantedApplicationRecord

  def self.id_for(country)
    find_by(name: country)&.id
  end

  def self.ids_for(countries)
    where(name: countries).pluck(:id)
  end

end


