class Docs::UtilityBills::Subscriptions::Action < ActionManager::API

  scope policy: Docs::UtilityBills::Subscriptions::Policy, model: BbpsBillerSubscription do
    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "utility_subscriptions.index"

    action :redirect,
           :create,
           format: 'primary',
           permissions: :utility_bill_master_initiator,
           label: 'Add Subscription',
           icon: 'https://img.icons8.com/windows/17/708090/--checkmark-yes.png',
           url: 'utility_bill_master'

    action :button_group,
           :actions,
           contextual: true,
           label: "Actions" do
      action :transition,
             :take_control,
             permissions: :admin,
             label: "Take Control",
             icon: "https://img.icons8.com/windows/17/708090/credit-control.png",
             url: "bbps/subscriptions/bulk_review.json?action_type=take_control",
             authorize: :take_control?
      action :transition,
             :return_control,
             permissions: :admin,
             label: "Return Control",
             icon: "https://img.icons8.com/windows/17/708090/credit-control.png",
             url: "bbps/subscriptions/bulk_review.json?action_type=return_control",
             authorize: :return_control?
      scope permissions: [:admin, :utility_bill_reviewer] do
        action :transition,
               :approve,
               label: "Approve",
               icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
               url: "bbps/subscriptions/bulk_review.json?action_type=approve",
               authorize: :approve?
        action :transition,
               :reject,
               label: "Reject",
               icon: "https://img.icons8.com/windows/17/708090/cancel-2.png",
               url: "bbps/subscriptions/bulk_review.json?action_type=reject",
               authorize: :reject?
      end
      action :transition,
             :deactivate,
             permissions: :admin,
             label: "Deactivate",
             icon: "https://img.icons8.com/windows/17/708090/credit-control.png",
             url: "bbps/subscriptions/bulk_review.json?action_type=deactivate",
             authorize: :deactivate?
      action :transition,
             :reactivate,
             permissions: :admin,
             label: "Activate",
             icon: "https://img.icons8.com/windows/17/708090/credit-control.png",
             url: "bbps/subscriptions/bulk_review.json?action_type=reactivate",
             authorize: :reactivate?
    end

  end

end