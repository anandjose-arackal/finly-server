class Docs::P2P::Invoices::Action < ActionManager::API

  scope policy: Docs::P2P::Invoices::Policy, model: Invoice do

    action :button_group,
           :actions,
           contextual: true,
           label: "Actions" do
      action :transition,
             :take_control,
             permissions: :admin,
             label: "Take Control",
             icon: "https://img.icons8.com/windows/17/708090/credit-control.png",
             url: "procure/inward_invoices/bulk_take_control.json",
             authorize: :take_control?
      scope permissions: [:admin, :po_invoice_reviewer, :non_po_invoice_reviewer, :agreement_invoice_reviewer] do
        action :transition,
               :approve,
               label: "Approve",
               icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
               url: "procure/inward_invoices/bulk_approve.json",
               authorize: :review?
        action :transition,
               :reject,
               label: "Reject",
               icon: "https://img.icons8.com/windows/17/708090/cancel-2.png",
               url: "procure/inward_invoices/bulk_reject.json",
               authorize: :review?
        action :reassign,
               :forward,
               label: "Forward",
               icon: "https://img.icons8.com/windows/17/708090/fast-forward.png",
               url: "procure/inward_invoices/forward.json",
               users_url: "forwardable_users.json",
               authorize: :review?
      end
    end

    action :macro,
           :jobs,
           policy: Macros::Jobs::Policy,
           authorize: :create?,
           route: 'invoices.index',
           label: "Jobs",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png"

    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "invoices.index"

    action :template,
           :create,
           format: 'primary',
           permissions: :non_po_invoice_initiator,
           label: "Create Non PO Invoice",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           function: "non_po_invoice_create"

  end

end