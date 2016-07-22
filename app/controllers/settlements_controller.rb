class SettlementsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_user, only: [:show, :show_partial, :add_payment]
  before_action :load_users, only: [:index]

  def add_payment
    ss = SettlementService.new(@user)
    result = nil
    param = payment_params
    if param[:payment_type] == PaymentType.advance_id.to_s
      result = ss.add_cash_advance(current_user, param[:date], param[:note], param[:amount], Currency.first.id)
    elsif param[:payment_type] == PaymentType.debt_clearance_id.to_s
      result = ss.add_debt_to_company_clearance(current_user, param[:date], param[:note], param[:amount], Currency.first.id)
    elsif param[:payment_type] == PaymentType.reimbursement_id.to_s
      report_ids = nil
      report_ids = param[:report_id].split if param[:report_id].present?
      result = ss.add_reimbursement(current_user, report_ids, param[:date], param[:note], param[:amount], Currency.first.id)
    end
    if result
      flash.now[:success] = 'Payment successfully added'
      redirect_to settlement_path(@user.id)
      return
    end
    flash.now[:danger] = 'Error adding payment'
    flash.now[:danger] = ss.errors if ss.errors.present?
    render_flash_message
  end

  def index
    @users = UserTeamService.new(current_user).team(UserRole.finance_manager_id, indirect_associations: true)
    @users = @users.with_balance_sheet if @users.present?
  end

  def show
    load_reports :approved
  end

  def show_partial
    case params[:view_to_load]
      when 'approved'
        load_reports :approved
      when 'reimbursed'
        load_reports :reimbursed
      when 'closed'
        load_reports :closed
      when 'payments'
        load_payments
    end
    respond_to do |format|
      format.js
    end
  end

  private
  def payment_params
    params.require(:payment).permit(:amount, :note, :date, :payment_type, :report_id)
  end

  def load_user
    user = current_user.company.users.find_by(id: params[:id])
    if user.present? and UserTeamService.new(current_user).finance_manager_for?(user, indirect_associations: true)
      @user = user
      return true
    end
    flash.now[:danger] = 'User not found'
    render_flash_message
    false
  end

  def load_users
    @users = UserTeamService.new(current_user).team(UserRole.finance_manager_id, indirect_associations: true)
    @users = @users.with_balance_sheet if @users.present?
  end

  def load_reports(type)
    r = @user.reports.send(type)
    @reports= []
    if r.present?
      r.each do |report|
        rds = ReportDetailService.new(report)
        @reports << {report: report, total_amount: rds.total_amount, final_approver: rds.final_approver}
      end
    end
    @load_type = {}
    case type
      when :approved
        @load_type[:approved] = true
      when :reimbursed
        @load_type[:reimbursed] = true
      when :closed
        @load_type[:closed] = true
    end
  end

  def load_payments
    @payments = @user.payments.with_details
    @load_type = {}
    @load_type[:payments] = true
  end

end
