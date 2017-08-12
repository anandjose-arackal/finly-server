require "#{Rails.root}/app/operations/settlement/index"
class Settlement::Show < Settlement::Base
  attr_accessor :selected_user, :reports, :payments, :money_requests, :type, :view_to_load

  include HasScope

  has_scope :with_application

  def pre_validate
    unless user.present?
      messages[:error] << 'User not found'
    end
    unless params[:view_to_load].present?
      messages[:error] << 'Error loading reports'
    end
  end

  def init
    self.type = {}
    self.view_to_load = params[:view_to_load]
    load_selected_user
  end

  def configure_expense_management
    params[:with_application] = RequestStore.store[:current_app].to_s
  end

  def process
    if self.view_to_load == 'payments'
      load_payments
    elsif self.view_to_load.include?('money_request')
      load_money_requests
    elsif view_to_load.include?('reports')
      load_reports
    end
    return if has_errors?
    self.type[view_to_load.to_sym] = true
  end

  def post_process
    super()
    if params[:ref] == '1' and params[:n_id].present?
      Event::EMoneyRequest::Unset.(user, params)
    end
  end

  def success
    params[:selected_user] = selected_user
    params[:reports] = reports.reorder(updated_at: :desc) if reports.present?
    params[:payments] = payments.reorder(updated_at: :desc) if payments.present?
    params[:money_requests] = money_requests.reorder(updated_at: :desc) if money_requests.present?
    params[:type] = type
    Settlement::Show::Presenter.new(user, params, messages)
  end

  class Settlement::Show::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :selected_user, :items, :type

    has_scope :with_application

    def init
      self.selected_user = params[:selected_user]
      self.items = (params[:reports] or apply_scopes(params[:payments], params) or params[:money_requests])
      self.type = params[:type]
    end

  end

  private
  def load_selected_user
    if personal_view?
      self.selected_user = self.user
      return
    end
    user_op = Settlement::Index.new(user, params)
    user_result = user_op.run
    unless user_op.success?
      self.messages[:error] = user_op.messages[:error]
      return
    end
    user_id = (params[:id] or params[:user_id])
    self.selected_user = user_result.users.with_id(user_id).first rescue nil
    if self.selected_user.blank?
      messages[:error] << 'User not found'
    end
  end

  def load_reports
    if self.view_to_load.blank?
      self.reports = self.selected_user.reports
    else
      self.reports = self.selected_user.reports.settlement_viewable
    end
    if view_to_load.include?('approved')
      self.reports = reports.approved
    end
  end

  def load_payments
    self.payments = self.selected_user.payments.non_settlement.with_details
  end

  def load_money_requests
    if self.view_to_load.blank?
      self.money_requests = selected_user.money_requests
    else
      self.money_requests = self.selected_user.money_requests.settlement_viewable
    end
    if view_to_load.include?('approved')
      self.money_requests = money_requests.approved
    end
  end

end
