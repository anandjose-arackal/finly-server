class Masters::Router < Routers::Base
  Routers::Registry.register :masters, self

  def self.masters
    masters = []
    map.each do |route, list|
      masters += list&.map {|item| item.klass}
    end
    masters
  end

  def self.klass(route)
    Masters::Router.map[route]&.first&.klass
  end

end
