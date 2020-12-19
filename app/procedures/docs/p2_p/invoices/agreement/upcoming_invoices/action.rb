class Docs::P2P::Invoices::Agreement::UpcomingInvoices::Action < ActionManager::API
  scope policy: Docs::P2P::Invoices::Policy, model: Invoice do

    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "upcoming_invoices.index"
  end
end