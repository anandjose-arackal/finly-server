class Docs::P2P::PurchaseRequests::Action < ActionManager::API

  scope policy: Docs::P2P::PurchaseRequests::Policy, model: PurchaseRequest do

    scope permissions: :admin do
      action :button_group,
             :actions,
             contextual: true,
             label: "Actions" do
        action :transition,
               :take_control,
               label: "Take Control",
               icon: "https://img.icons8.com/windows/17/708090/credit-control.png",
               url: "procure/purchase_requests/bulk_take_control.json"
        scope permissions: :purchase_request_reviewer do
          action :transition,
                 :approve,
                 label: "Approve",
                 icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
                 url: "procure/purchase_requests/bulk_approve.json",
                 authorize: :review?
          action :transition,
                 :reject,
                 label: "Reject",
                 icon: "https://img.icons8.com/windows/17/708090/cancel-2.png",
                 url: "procure/purchase_requests/bulk_reject.json",
                 authorize: :review?
          action :transition,
                 :destroy,
                 label: "Delete",
                 icon: "https://img.icons8.com/windows/17/708090/cancel-2.png",
                 url: "procure/purchase_requests/bulk_destroy.json",
                 authorize: :destroy?
        end
      end
    end

    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "purchase_requests.index",
           authorize: :export?

    action :redirect,
           :create,
           format: 'primary',
           permissions: :purchase_request_initiator,
           label: 'New Purchase Request',
           icon: 'https://img.icons8.com/windows/17/708090/--checkmark-yes.png',
           url: 'purchase_requests/new'

  end

end