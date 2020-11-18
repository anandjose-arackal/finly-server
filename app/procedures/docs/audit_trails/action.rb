class Docs::AuditTrails::Action < ActionManager::API

  scope policy: Docs::AuditTrails::Policy , model: PaperTrail::Version do

    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "audit_trails.index"

  end

end