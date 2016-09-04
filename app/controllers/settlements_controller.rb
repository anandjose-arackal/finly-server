class SettlementsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_user, only: [:show, :show_partial, :add_payment]
  before_action :load_users, only: [:index]

  def create

    params[:to_user_id] = @user
    result = nil
    # param = payment_params
    success_message = nil
    error_message = nil
    if param[:payment_type] == PaymentType.advance_id.to_s
      cash_advance_op = Settlement::AddCashAdvance.new(current_user, params)
      result = cash_advance_op.run
      # result = ss.add_cash_advance(current_user, param[:date], param[:note], param[:amount], Currency.first.id)
      if result
        success_message = 'Cash advance added'
      else
        error_message = cash_advance_op.errors
      end
    elsif param[:payment_type] == PaymentType.debt_clearance_id.to_s
      debt_to_company_clearance_op = Settlement::AddDebtToCompanyClearance.new(current_user, params)
      result = debt_to_company_clearance_op.run
      # result = ss.add_debt_to_company_clearance(current_user, param[:date], param[:note], param[:amount], Currency.first.id)
      if result
        success_message = 'debt clearance payment added'
      else
        error_message = debt_to_company_clearance_op.errors
      end
    elsif param[:payment_type] == PaymentType.reimbursement_id.to_s
      reimbursement_op = Settlement::AddReimbursement.new(current_user, params)
      result = reimbursement_op.run
      # result = ss.add_reimbursement(current_user, report_ids, param[:date], param[:note], param[:amount], Currency.first.id)
      if result
        success_message = 'Reimbursement added'
      else
        error_message = reimbursement_op.error
      end
    elsif param[:payment_type] == PaymentType.settlement_id.to_s
      settle_op = Settlement::Settle.new(current_user, params)
      result = settle_op.run
      if result
        success_message = 'Payment settled'
      else
        error_message = settle_op.errors
      end
      # result = ss.settle(current_user, report_ids, param[:date], param[:note], param[:amount], Currency.first.id)
    end

    if result
      flash.now[:success] = 'payment successfully added'
      flash.now[:success] = success_message if success_message.present?
      redirect_to settlement_path(@user.id, view: params[:view])
      return
    end
    flash.now[:danger] = error_message
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

    @actions = Settlement::ShowActions.(current_user, params)

    respond_to do |format|
      format.html {}
      format.js {}
      format.json {}
    end
  end

  def summary
    puts "Hello"
    @user = current_company.users.find_by(id: params[:id])
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
          admin_team = User::Team::Index.(current_user, role_id: UserRole.admin_id).team
          # admin_team = UserTeamService.new(current_user).team(UserRole.admin_id)
          if admin_team and admin_team.with_id(params[:id]).present?
            @user = user
            return true
          end
        end
      end
    elsif @finance_view
      # todo - change this to operation
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
      @users = User::Team::Index.(current_user, role_id: UserRole.admin_id, indirect_associations: true).team
      # @users = UserTeamService.new(current_user).team(UserRole.admin_id, indirect_associations: true)
    elsif @finance_view
      @users = User::Team::Index.(current_user, role_id: UserRole.finance_manager_id, indirect_associations: true).team
      # @users = UserTeamService.new(current_user).team(UserRole.finance_manager_id, indirect_associations: true)
    end
    @users = @users.with_balance_sheet if @users.present?
  end

  def load_reports(type)
    r = @user.reports.send(type)
    @reports= []
    if r.present?
      r.each do |report|
        reimbursement_amount = 0
        reimbursement_amount = report.reimbursement_amount.value if report.reimbursement_amount.present?
        @reports << {report: report, reimbursement_amount: reimbursement_amount, total_amount: report.total_amount, final_approver: report.final_approver}
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
