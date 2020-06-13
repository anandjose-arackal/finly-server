class Docs::UtilityBills::Bills::Action < ActionManager::API

  scope policy: Docs::UtilityBills::Bills::Policy, model: BbpsBill do
    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "utility_bills.index"
    action :button_group,
           :actions,
           contextual: true,
           label: "Actions" do
      action :transition,
             :take_control,
             permissions: :admin,
             label: "Take Control",
             icon: "https://img.icons8.com/windows/17/708090/credit-control.png",
             url: "bbps/bills/bulk_review.json?action_type=take_control",
             authorize: :take_control?
      action :transition,
             :return_control,
             permissions: :admin,
             label: "Return Control",
             icon: "https://img.icons8.com/windows/17/708090/credit-control.png",
             url: "bbps/bills/bulk_review.json?action_type=return_control",
             authorize: :return_control?
      scope permissions: [:admin, :utility_bill_reviewer] do
        action :transition,
               :approve,
               label: "Approve",
               icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
               url: "bbps/bills/bulk_review.json?action_type=approve",
               authorize: :approve?
        action :transition,
               :reject,
               label: "Reject",
               icon: "https://img.icons8.com/windows/17/708090/cancel-2.png",
               url: "bbps/bills/bulk_review.json?action_type=reject",
               authorize: :reject?
      end
    end
  end

end