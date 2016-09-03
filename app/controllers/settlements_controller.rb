class SettlementsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_user, only: [:show, :show_partial, :add_payment]
  before_action :load_users, only: [:index]

  def add_payment
    authorize Payment
    ss = SettlementService.new(@user)
    result = nil
    param = payment_params
    success_message = nil
    if param[:payment_type] == PaymentType.advance_id.to_s
      result = ss.add_cash_advance(current_user, param[:date], param[:note], param[:amount], Currency.first.id)
      success_message = 'advance added'
    elsif param[:payment_type] == PaymentType.debt_clearance_id.to_s
      result = ss.add_debt_to_company_clearance(current_user, param[:date], param[:note], param[:amount], Currency.first.id)
      success_message = 'debt clearance payment added'
    elsif param[:payment_type] == PaymentType.reimbursement_id.to_s
      report_ids = nil
      report_ids = param[:report_id].split if param[:report_id].present?
      result = ss.add_reimbursement(current_user, report_ids, param[:date], param[:note], param[:amount], Currency.first.id)
      success_message = 'reimbursement added'
    elsif param[:payment_type] == PaymentType.settlement_id.to_s
      report_ids = nil
      report_ids = param[:report_id].split if param[:report_id].present?
      result = ss.settle(current_user, report_ids, param[:date], param[:note], param[:amount], Currency.first.id)
      success_message = 'settlement created'
    end

    if result
      flash.now[:success] = 'payment successfully added'
      flash.now[:success] = success_message if success_message.present?
      redirect_to settlement_path(@user.id, view: params[:view])
      return
    end
    flash.now[:danger] = 'error adding payment'
    flash.now[:danger] = ss.errors if ss.errors.present?
    render_flash_message
  end

  def index
    # authorize Payment
    @users = @users.with_roles.only_employees.paginate(page: params[:page], per_page: 30) if @users.present?

    respond_to do |format|
      format.html {}
      format.js {}
      format.json {render json: @users.as_json}
    end
  end

  def show
    # Previsous Code
    # return unless PaymentPolicy.new(current_user, @user).show?
    # load_reports :approved

    # Backbone Code
    return unless PaymentPolicy.new(current_user, @user).show?
    # load_reports :approved
    case params[:view_to_load]
      when 'approved'
        load_reports :approved
      when 'reimbursed'
        load_reports :reimbursed
      when 'closed'
        load_reports :closed
      when 'payments'
        load_payments
      else
        load_reports :approved
    end


    respond_to do |format|
      format.html {}
      format.js {}
      format.json {}
    end
  end

  def summary
    puts "Hello"
    @user = User.find(params[:id])
    respond_to do |format|
      format.json {}
    end
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
    user = current_company.users.find_by(id: params[:id])
    if @admin_view
      if user.present?
        if current_user.company_admin?
          @user = user
          return true
        elsif current_user.policy_admin?
          admin_team = UserTeamService.new(current_user).team(UserRole.admin_id)
          if admin_team and admin_team.with_id(params[:id]).present?
            @user = user
            return true
          end
        end
      end
    elsif @finance_view
      if user.present? and UserTeamService.new(current_user).finance_manager_for?(user, indirect_associations: true)
        @user = user
        return true
      end
    elsif @personal_view
      @user = current_user
      return true
    end
    flash.now[:danger] = 'user not found'
    render_flash_message
    false
  end

  def load_users
    if @admin_view
      @users = UserTeamService.new(current_user).team(UserRole.admin_id, indirect_associations: true)
    elsif @finance_view
      @users = UserTeamService.new(current_user).team(UserRole.finance_manager_id, indirect_associations: true)
    end
    @users = @users.with_balance_sheet if @users.present?
  end

  def load_reports(type)
    r = @user.reports.send(type)
    @reports= []
    if r.present?
      r.each do |report|
        rds = ReportDetailService.new(report)
        reimbursement_amount = 0
        reimbursement_amount = report.reimbursement_amount.value if report.reimbursement_amount.present?
        @reports << {report: report, reimbursement_amount: reimbursement_amount, total_amount: rds.total_amount, final_approver: rds.final_approver}
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
