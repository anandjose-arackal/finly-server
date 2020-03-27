class Docs::P2P::Invoices::Po::Action < ActionManager::API

  scope policy: "Docs::P2P::Invoices::Po::Policy" do

    action :template,
           label: "Create Non PO Invoice",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           function: "non_po_invoice_create"

      scope permissions: :admin do
        action :transition,
               label: "Take Control",
               icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
               url: "procure/inward_invoices/bulk_approve.json",
               authorize: :take_control?
      end

      scope permissions: :po_invoice_reviewer do
        action :transition,
               label: "Approve",
               icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
               url: "procure/inward_invoices/bulk_approve.json",
               authorize: :reject?
        action :transition,
               label: "Reject",
               icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
               url: "procure/inward_invoices/bulk_approve.json",
               authorize: :reject?
        action :reassign,
               label: "Forward",
               icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
               url: "procure/inward_invoices/bulk_approve.json",
               authorize: :forward?
      end

      action :export,
             label: "Export",
             icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
             route: "invoices.index",
             authorize: :export?

  end

end