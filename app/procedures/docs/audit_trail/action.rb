class Docs::AuditTrail::Action < ActionManager::API

  scope policy: Docs::AuditTrail::Policy , model: PaperTrail::Version do

    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "purchase_orders.index"

  end

end