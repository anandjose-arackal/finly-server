class Docs::P2P::PurchaseOrders::Action < ActionManager::API

  scope policy: Docs::P2P::PurchaseOrders::Policy, model: PurchaseOrder do

    action :button_group,
           :actions,
           contextual: true,
           label: "Actions" do
      action :transition,
             :take_control,
             permissions: :admin,
             label: "Take Control",
             icon: "https://img.icons8.com/windows/17/708090/credit-control.png",
             url: "procure/purchase_orders/bulk_take_control.json",
             authorize: :take_control?
      scope permissions: :purchase_order_reviewer do
        action :transition,
               :approve,
               label: "Approve",
               icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
               url: "procure/purchase_orders/bulk_approve.json",
               authorize: :review?
        action :transition,
               :reject,
               label: "Reject",
               icon: "https://img.icons8.com/windows/17/708090/cancel-2.png",
               url: "procure/purchase_orders/bulk_reject.json",
               authorize: :review?
        action :reassign,
               :forward,
               label: "Forward",
               icon: "https://img.icons8.com/windows/17/708090/fast-forward.png",
               url: "procure/purchase_orders/forward.json",
               users_url: "forwardable_users.json",
               authorize: :review?
      end
    end

    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "purchase_orders.index"

    action :template,
           :create,
           permissions: :purchase_order_initiator,
           format: 'primary',
           label: 'Create PO',
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           function: "po_create"

  end

end