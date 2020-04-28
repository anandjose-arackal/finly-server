class Docs::PaymentTickets::Action < ActionManager::API

  scope policy: Docs::PaymentTickets::Policy, model: BankPaymentRequest do

    action :button_group,
           :actions,
           contextual: true,
           label: "Actions" do
      action :transition,
             :take_control,
             permissions: :admin,
             label: "Take Control",
             icon: "https://img.icons8.com/windows/17/708090/credit-control.png",
             url: "bank_transfer/bulk_take_control.json",
             authorize: :take_control?
      scope permissions: :bank_payment_request_reviewer do
        action :transition,
               :approve,
               label: "Approve",
               icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
               url: "bank_transfer/bulk_approve.json",
               authorize: :review?
        action :transition,
               :reject,
               label: "Reject",
               icon: "https://img.icons8.com/windows/17/708090/cancel-2.png",
               url: "bank_transfer/bulk_reject.json",
               authorize: :review?
      end
      scope permissions: :bank_payment_request_creditor do
        action :transition,
               :mark_as_credited,
               label: "Mark as Credited",
               icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
               url: "bank_transfer/mark_as_credited.json",
               authorize: :mark_as_credited?
        action :transition,
               :credit,
               label: "Credit",
               icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
               url: "bank_transfer/bulk_credit.json",
               otp: true, password: true,
               authorize: :credit?
      end
    end

    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "payment_ticket.index"

    action :redirect,
           :create,
           format: 'primary',
           permissions: :bank_payment_request_initiator,
           label: 'New Payment Ticket',
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           url: 'new_payment_ticket'

  end

end