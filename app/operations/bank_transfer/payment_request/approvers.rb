# this operation will extract all the approvers of a Bank Payment Request till a particular user (i.e. the controlling user)
# If not controlling user is passed, it retrieves all users in the chain
class BankTransfer::PaymentRequest::Approvers < BankTransfer::PaymentRequest::Base

  attr_accessor :approvers, :bank_payment_request, :till_user, :reviewer, :reviewer_role

  class BankTransfer::PaymentRequest::Approvers::ApproversPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :approvers

    def init
      self.approvers = params[:approvers]
    end

  end

  def authorized_user_types
    nil
  end

  def pre_validate
    if params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def initialize(params = {})
    self.params = (ActionController::Parameters.new(params) or {})
  end

  def self.call(params = {})
    self.new(params).run
  end

  def init
    # id = params[:id] || params[:bank_payment_request_id]
    # self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: id) rescue nil
    self.bank_payment_request = params[:bank_payment_request]
    self.user = self.bank_payment_request.user
    self.approvers = []
  end

  def validate
    if self.bank_payment_request.blank?
      add_message :error, "Payment Order not found"
    end
  end

  def process
    # run a loop till the next_reviewer is the current user
    self.reviewer = bank_payment_request.owner
    self.reviewer_role = UserRole.id_for(:employee)
    # first generate the owner's entry in the approvers hash
    self.approvers << {
        approved: false,
        controlling_user: true,
        approver: {
            name: bank_payment_request.owner.name,
            email: bank_payment_request.owner.email,
            mobile_number: bank_payment_request.owner.mobile_number
        },
        role: {
            id: UserRole.id_for(:employee),
            name: UserRole.name_for(UserRole.id_for(:employee))
        },
    }
    associated_users = BankTransfer::PaymentRequest::Review::AssociatedUsers.(self.user, bank_payment_request: self.bank_payment_request)
    op = User::Team::Review::NextReviewer.(bank_payment_request, controlling_user: self.reviewer, controlling_user_role_id: self.reviewer_role)
    self.reviewer = op.user
    self.reviewer_role = op.role_id
    if self.reviewer.blank?
      self.approvers.first[:auto_approve] = true
      self.approvers.first[:title] = "This payment order will be auto approved as there is no reviewer assigned"
    end
    while self.reviewer.present?
      self.approvers << {
          approved: associated_users.include?(self.reviewer),
          controlling_user: (self.reviewer.id == bank_payment_request.controlling_user_id),
          approver: {
              name: self.reviewer.name,
              email: self.reviewer.email,
              mobile_number: self.reviewer.mobile_number
          },
          role: {
              id: self.reviewer_role,
              name: UserRole.name_for(self.reviewer_role)
          },
          title: associated_users.include?(self.reviewer) ? "#{self.reviewer.name} has approved the payment order" : "",
          approved_at: (bank_payment_request.verified? ? bank_payment_request.approved_at : nil)
      }
      op = User::Team::Review::NextReviewer.(bank_payment_request, controlling_user: self.reviewer, controlling_user_role_id: self.reviewer_role)
      self.reviewer = op.user
      self.reviewer_role = op.role_id
    end
  end

  def success
    params[:approvers] = self.approvers
    BankTransfer::PaymentRequest::Approvers::ApproversPresenter.new(user, params, messages)
  end
end