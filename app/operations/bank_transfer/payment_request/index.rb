# this operation should return the list of payment requests that a particular user
# has access to from the index screen - based on the approval flow logic
# essentially, payment orders that one owns, and payment orders that
class BankTransfer::PaymentRequest::Index < BankTransfer::PaymentRequest::Base

  attr_accessor :role_id, :payment_requests

  def pre_validate
    super

  end

  def init
    self.role_id = params[:role_id]
    if self.role_id.blank? and params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
  end

  def authorize
    if self.role_id.blank?
      unless user.payment_initiator?
        add_message :error, "You are not authorized for this operation"
      end
    end
  end

  def process
    case self.role_id
      when UserRole.id_for(:admin)
        if self.user.company_admin?
          team_ids = User::Team::Index.(user, role_id: UserRole.id_for(:admin))&.pluck(:id)
          self.payment_requests = BankPaymentRequest.not_open.with_user(team_ids)
        end
        unless user.admin?
          messages[:error] << 'User is not an admin'
          return false
        end
      when UserRole.id_for(:manager)
        team_ids = User::Team::Index.(user, role_id: UserRole.id_for(:manager))&.pluck(:id)
        controlling_payment_requests_query = user.controlling_payment_requests.non_owner(user.id).with_controlling_user_role(UserRole.manager_id).with_user(team_ids)
        interacted_payment_requests_query= user.manager_payment_requests
        sql = BankPaymentRequest.connection.unprepared_statement {
          "((#{controlling_payment_requests_query.to_sql}) UNION (#{interacted_payment_requests_query.to_sql})) AS bank_payment_requests"
        }
        self.payment_requests = BankPaymentRequest.from([Arel.sql(sql)])
      when UserRole.id_for(:finance_manager)
        team_ids = User::Team::Index.(user, role_id: UserRole.id_for(:finance_manager))&.pluck(:id)
        controlling_payment_requests_query = user.controlling_payment_requests.non_owner(user.id).with_controlling_user_role(UserRole.finance_manager_id).with_user(team_ids)
        interacted_payment_requests_query = user.finance_payment_requests
        sql = BankPaymentRequest.connection.unprepared_statement {
          "((#{controlling_payment_requests_query.to_sql}) UNION (#{interacted_payment_requests_query.to_sql})) AS bank_payment_requests"
        }
        self.payment_requests = BankPaymentRequest.from([Arel.sql(sql)])
      else
        self.payment_requests = user.payment_requests
    end
  end

  def success
    params[:payment_requests] = self.payment_requests
    BankTransfer::PaymentRequest::Index::PaymentPresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::Index::PaymentPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payment_requests

    def init
      self.payment_requests = params[:payment_requests]
    end
  end

end