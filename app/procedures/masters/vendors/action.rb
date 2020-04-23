class Masters::Vendors::Action < ActionManager::API

  scope policy: Masters::Vendors::Policy, model: YesBankVendor do

    scope permissions: :admin do
      action :button_group,
             :actions,
             contextual: true,
             label: "Actions" do
        action :transition,
               :take_control,
               label: "Take Control",
               icon: "https://img.icons8.com/windows/17/708090/credit-control.png",
               url: "vendors/bulk_take_control.json",
               authorize: :take_control?
        scope permissions: :vendor_reviewer do
          action :transition,
                 :approve,
                 label: "Approve",
                 icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
                 url: "vendors/bulk_approve.json",
                 authorize: :review?
          action :transition,
                 :reject,
                 label: "Reject",
                 icon: "https://img.icons8.com/windows/17/708090/cancel-2.png",
                 url: "vendors/bulk_reject.json",
                 authorize: :review?
        end
      end
    end

    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "vendors.index"

    action :redirect,
           :create,
           permissions: [:vendor_creator, :vendor_manager],
           format: 'primary',
           label: 'Add Vendor',
           icon: 'https://img.icons8.com/windows/17/708090/--checkmark-yes.png',
           url: 'vendor/add'

  end

end