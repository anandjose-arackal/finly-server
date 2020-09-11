class Events::Router < Routers::Base
  Routers::Registry.register :events, self

  allow_multiple_associations!

end