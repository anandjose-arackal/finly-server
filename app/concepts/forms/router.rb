class Forms::Router < Routers::Base
  Routers::Registry.register :forms, self

  def self.forms
    forms = []
    map.each do |route, list|
      forms += list&.map {|item| item.klass}
    end
    forms
  end

end
