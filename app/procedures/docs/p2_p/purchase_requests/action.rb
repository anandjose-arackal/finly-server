class Docs::P2P::PurchaseRequests::Action < ActionManager::API

  scope policy: Docs::P2P::PurchaseRequests::Policy, model: YesBankVendor do

    scope permissions: :admin do
      action :button_group,
             :actions,
             contextual: true,
             label: "Actions" do
        scope permissions: :purchase_request_reviewer do
          action :transition,
                 :approve,
                 label: "Approve",
                 icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
                 url: "/procure/purchase_requests/bulk_approve.json",
                 authorize: :approve?
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
           url: 'purchase_request'

  end

end