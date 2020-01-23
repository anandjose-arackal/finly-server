# Add version before revision and archive
# Copy data to newly revised agreement and allow to edit it
# Revised payment agreement is now the primary/default payment agreement
# Allow revision only if no invoice has been created from the agreement invoice template

class PaymentAgreements::Revise < PaymentAgreements::Base

  attr_accessor :payment_agreement, :revised_agreement

  def init
    id = params[:id] || params[:payment_agreement_id]
    self.payment_agreement = user.company.payment_agreements.find_by_id id
  end

  def validate
    if payment_agreement.blank?
      add_message :error, 'Payment agreement not found'
    end
  end

  def process
    params[:document] = self.payment_agreement
    params[:aasm_event] = 'revise'

    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
    create_revised_agreement
  end

  def success
    params[:revised_agreement] = self.revised_agreement
    PaymentAgreements::Revise::RevisePresenter.new(user, params, messages)
  end

  class PaymentAgreements::Revise::RevisePresenter < BaseOperation::BasePresenter::SuccessPresenter
    
    attr_accessor :revised_agreement, :payment_agreement
    def init
      # self.payment_agreement = params[:payment_agreement]
      self.revised_agreement = params[:revised_agreement]
    end
  end

  def post_process
    add_message :success, "You have revised the agreement"
  end

  private

  def create_revised_agreement
    self.revised_agreement = self.payment_agreement.amoeba_dup
    self.revised_agreement.revision_of_pa_id = self.payment_agreement.id
    self.revised_agreement.save
  end
end