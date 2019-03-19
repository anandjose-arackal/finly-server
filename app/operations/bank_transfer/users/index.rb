# this operation is for listing the users in the 'Users' tab in the vendor payments
# application

class BankTransfer::Users::Index < BankTransfer::Users::Base

  attr_accessor :users, :role_id

  def authorized_user_types
    [:vendor_payments_admin, :auditor]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    # initialize the role id for a particular user
    self.role_id = params[:role_id]
    if self.role_id.blank? && params[:view].present?
      if params[:view] == 'finance'
        params[:view] = 'finance_manager'
      end
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
    params[:with_application] = RequestStore.store[:current_app].to_s
  end

  def configure_vendor_payment
    params[:filter_vendor_payments] = '1'
  end

  def validate
    unless role_id.present?
      add_message :error, "User role not defined"
    end
  end

  def process
    case role_id
      when UserRole.id_for(:admin), UserRole.id_for(:auditor)
        self.users = user.company.users
      else
        self.users = []
    end
  end

  def success
    params[:users] = users
    BankTransfer::Users::Index::UsersPresenter.new(user, params, messages)
  end

  class BankTransfer::Users::Index::UsersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :users, :paginated_team

    has_scope :filter_search
    has_scope :filter_state, type: :array
    has_scope :filter_role, type: :array
    has_scope :filter_vendor_payments
    has_scope :filter_unassigned_purchase_order_initiator_for_policy
    has_scope :filter_unassigned_purchase_order_reviewer_for_policy
    has_scope :filter_unassigned_goods_receiver_for_policy
    has_scope :filter_unassigned_invoice_initiator_for_policy
    has_scope :filter_unassigned_invoice_reviewer_for_policy
    has_scope :filter_unassigned_bank_payment_request_initiator_for_policy
    has_scope :filter_unassigned_bank_payment_request_reviewer_for_policy
    has_scope :filter_unassigned_bank_payment_request_creditor_for_policy
    has_scope :filter_unassigned_item_master_manager_for_policy
    has_scope :filter_unassigned_vendor_creator_for_policy
    has_scope :filter_unassigned_vendor_reviewer_for_policy
    has_scope :filter_unassigned_vendor_manager_for_policy
    has_scope :filter_unassigned_budget_manager_for_policy

    def init
      fix_scopes
      self.users = params[:users]
      self.users = apply_scopes(users, params)
      self.paginated_team = users.paginate(page: params[:page], per_page: params[:per_page] || 30)
    end

    def fix_scopes
      ScopeUtils.fix_for_scoping(params, :filter_role, :array)
      ScopeUtils.fix_for_scoping(params, :filter_state, :array)
    end
  end


end
