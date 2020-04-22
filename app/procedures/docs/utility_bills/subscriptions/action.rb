class Docs::UtilityBills::Subscriptions::Action < ActionManager::API

  scope policy: Docs::UtilityBills::Subscriptions::Policy, model: BbpsBill do

    action :button_group,
           :actions,
           contextual: true,
           label: "Actions" do
      scope permissions: :admin do
        action :transition,
               :take_control,
               label: "Take Control",
               icon: "https://img.icons8.com/windows/17/708090/credit-control.png",
               url: "procure/inward_invoices/bulk_take_control.json",
               authorize: :take_control?
        scope permissions: :po_invoice_reviewer do
          action :transition,
                 :approve,
                 label: "Approve",
                 icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
                 url: "procure/inward_invoices/bulk_approve.json",
                 authorize: :reject?
          action :transition,
                 :reject,
                 label: "Reject",
                 icon: "https://img.icons8.com/windows/17/708090/cancel-2.png",
                 url: "procure/inward_invoices/bulk_reject.json",
                 authorize: :reject?
          action :reassign,
                 :forward,
                 label: "Forward",
                 icon: "https://img.icons8.com/windows/17/708090/fast-forward.png",
                 url: "procure/inward_invoices/forward.json",
                 users_url: "forwardable_users.json",
                 authorize: :forward?
        end
      end
    end

    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "invoices.index",
           authorize: :export?

  end

end