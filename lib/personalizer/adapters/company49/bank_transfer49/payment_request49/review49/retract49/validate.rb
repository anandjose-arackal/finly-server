class Personalizer::Adapters::Company49::BankTransfer49::PaymentRequest49::Review49::Retract49::Validate < Personalizer::Adapters::Base
  attr_accessor :bank_payment_request

  def init
    self.bank_payment_request = self.op_instance.bank_payment_request
  end

  # If Niranjan has approved as a creditor, then prevent the payment request from being retracted
  def validate
    niranjan_id = 887
    roles = [UserRole.id_for(:creditor),UserRole.id_for(:admin)]
    action = BankPaymentRequestTrailAction.id_for(:approve)
    if self.bank_payment_request.bank_payment_request_trails.with_action_user(niranjan_id)
           .with_action_user_role(roles).with_action(action).present?
      add_message :error, 'The payment ticket cannot be retracted in the current stage'
    end
  end

end