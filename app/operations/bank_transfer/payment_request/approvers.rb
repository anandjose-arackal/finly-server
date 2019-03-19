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
    super(nil, params)
  end

  def self.call(params = {})
    self.new(params).run
  end

  def init
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

    op = User::Team::Review::NextReviewer.(bank_payment_request, controlling_user: self.reviewer, controlling_user_role_id: self.reviewer_role)
    first_reviewer = op.user

    # checking if the particular payment order can be auto approved
    if first_reviewer.blank?
      self.approvers << {
          controlling_user: bank_payment_request.can_submit?,
          action_id: nil,
          owner: true,
          action_user: {
              name: bank_payment_request.owner.name,
              email: bank_payment_request.owner.email,
              mobile_number: bank_payment_request.owner.mobile_number
          },
          role: {
              id: UserRole.id_for(:employee),
              name: UserRole.name_for(UserRole.id_for(:employee))
          },
          auto_approve: true,
          title: "This payment order will be auto approved as there is no reviewer assigned"
      }
      return
    end

    # now extract all the users from the track
    trails = BankTransfer::PaymentRequest::Review::ApproveUnapproveBlock.(user, id: bank_payment_request.id)
    trails.each do |trail|
      self.approvers << {
          action_id: trail.action_id,
          controlling_user: false,
          action_user: {
              name: trail.action_user&.name,
              email: trail.action_user&.email,
              mobile_number: trail.action_user&.mobile_number,
          },
          role: {
              id: trail.action_user_role_id,
              name: UserRole.name_for(trail.action_user_role_id)
          }
      }
      self.reviewer = trail.action_user
      self.reviewer_role = trail.action_user_role_id
    end

    # adding the controlling user of the particular bank payment request if they're present
    if bank_payment_request.controlling_user.present?
      self.approvers << {
          action_id: nil,
          controlling_user: true,
          owner: (bank_payment_request.controlling_user_id == bank_payment_request.owner&.id),
          action_user: {
              name: bank_payment_request.controlling_user&.name,
              email: bank_payment_request.controlling_user&.email,
              mobile_number: bank_payment_request.controlling_user&.mobile_number,
          },
          role: {
              id: bank_payment_request.controlling_user_role_id,
              name: UserRole.name_for(bank_payment_request.controlling_user_role_id)
          }
      }
    end
    self.reviewer = bank_payment_request.controlling_for_user || bank_payment_request.controlling_user
    self.reviewer_role = bank_payment_request.controlling_for_user_role_id

    # now extracting all pending approvers (assuming there's not take control action here)
    op = User::Team::Review::NextReviewer.(bank_payment_request, controlling_user: self.reviewer, controlling_user_role_id: self.reviewer_role)

    self.reviewer = op.user
    self.reviewer_role = op.success? ? op.role_id : nil

    reviewer_ids = {}
    while self.reviewer.present? && (reviewer_ids[self.reviewer_role].blank? or !reviewer_ids[self.reviewer_role].include?(self.reviewer&.id))
      self.approvers << {
          controlling_user: (self.reviewer.id == bank_payment_request.controlling_user_id and self.reviewer_role == bank_payment_request.controlling_user_role_id),
          rejected: false,
          action_user: {
              name: self.reviewer.name,
              email: self.reviewer.email,
              mobile_number: self.reviewer.mobile_number
          },
          role: {
              id: self.reviewer_role,
              name: UserRole.name_for(self.reviewer_role)
          },
          title: "",
          timestamp: (bank_payment_request.verified? ? bank_payment_request.approved_at : nil)
      }

      if reviewer_ids[self.reviewer_role].nil?
        reviewer_ids[self.reviewer_role]= []
      end
      # adding this reviewer to the list of previous reviewers
      reviewer_ids[self.reviewer_role] << self.reviewer&.id
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