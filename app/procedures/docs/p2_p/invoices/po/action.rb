class Docs::P2P::Invoices::Po::Action

  scope policy: Docs::P2P::Invoices::Po::Policy do

    action :create,
           label: "Create Non PO Invoice",
           icon: ""

    scope permissions: :admin do
      review label: "Take Control",
             icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
             url: "procure/inward_invoices/bulk_approve.json",
             policy_check: :take_control?
    end

    scope permissions: :po_invoice_reviewer do
      review label: "Approve",
             icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
             url: "procure/inward_invoices/bulk_approve.json",
             policy_check: :reject?
      review label: "Reject",
             icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
             url: "procure/inward_invoices/bulk_approve.json",
             policy_check: :reject?
      review label: "Forward",
             icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
             url: "procure/inward_invoices/bulk_approve.json",
             policy_check: :forward?
    end

    export label: "Export",
           config: "",
           policy_check: :export?

  end

end