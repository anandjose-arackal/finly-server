class AutoComplete::Router < Routers::Base
  Routers::Registry.register :auto_complete, self


end
require_dependency Rails.root.join("app/concepts/auto_complete/routes")