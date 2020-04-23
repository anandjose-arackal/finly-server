class Docs::UtilityBills::Bills::Action < ActionManager::API

  scope policy: Docs::UtilityBills::Bills::Policy, model: BbpsBill do
    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "utility_bills.index"
  end

end