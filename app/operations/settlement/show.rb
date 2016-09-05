require "#{Rails.root}/app/operations/settlement/index"
class Settlement::Show < Settlement::Base
  attr_accessor :selected_user, :reports, :payments, :actions, :type, :view_to_load

  def pre_validate
    unless user.present?
      errors << 'User not found'
    end
    unless params[:view_to_load].present?
      errors << 'Error loading reports'
    end
  end

  def init
    self.type = {}
    self.view_to_load = params[:view_to_load]
  end

  def process
    load_selected_user
    return unless errors.blank?
    if self.view_to_load == 'payments'
      load_payments
    else
      load_reports
    end
    return unless errors.blank?
    self.type[view_to_load.to_sym] = true
    load_actions
  end

  def success
    params[:selected_user] = selected_user
    params[:reports] = reports
    params[:payments] = payments
    params[:actions] = actions
    params[:type] = type
    Settlement::Show::Presenter.new(user, params)
  end

  class Settlement::Show::Presenter < BaseOperation::BasePresenter
    attr_accessor :selected_user, :items, :actions, :type

    def initialize(user, params)
      super(user, params)
      self.selected_user = params[:selected_user]
      self.items = (params[:reports] or params[:payments])
      self.actions = params[:actions]
      self.type = params[:type]
    end

    def reimbursement_amount_for_report(report)
      return 0 unless report.present?
      if report.reimbursement_amount.present?
        report.reimbursement_amount.value
      else
        0
      end
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
    unless user_op.is_success?
      self.errors = user_op.errors
      return
    end
    user_id = (params[:id] or params[:user_id])
    self.selected_user = user_result.users.with_id(user_id).first rescue nil
    if self.selected_user.blank?
      errors << 'User not found'
    end
  end

  def load_reports
    self.reports = self.selected_user.reports.send(self.view_to_load)
  end

  def load_payments
    self.payments = self.selected_user.payments.with_details
  end

  def load_actions
    return unless admin_view? or finance_view?
    return if self.selected_user.id == user.id and not admin_view?
    self.actions = {}
    self.actions[:add_reimbursement] = {url: Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.reimbursement_id.to_s)}
    self.actions[:settle] = {url: Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.settlement_id)}
    self.actions[:debt_to_clearance] = {url: Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.debt_clearance_id)}
    self.actions[:add_cash_advance] = {url: Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.advance_id)}
  end

end