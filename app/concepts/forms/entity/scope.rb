class Forms::Entity::Scope

  def self.List(*args)
    {choices: args&.map {|m| m.slice(:value, :name, :active)}}
  end

  def self.AutoComplete(route, filters: {})
    {auto_complete: {route: route, filters: filters}}
  end

  def self.Enum(klass, *keys)
    {enum: klass, keys: keys}
  end

  def self.Resolver(klass, *keys)
    {resolver: klass, keys: keys}
  end

end