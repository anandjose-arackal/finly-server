class SettlementsController < ApplicationController
  before_action :authenticate_user!
  allow_oauth!

  def create
    success_message = nil
    operation = nil
    if params[:payment_type] == PaymentType.id_for(:add_cash_on_hand).to_s
      operation = Settlement::Payment::AddCashAdvance.new(current_user, params)
    elsif params[:payment_type] == PaymentType.id_for(:deduct_cash_on_hand).to_s
      operation = Settlement::Payment::AddDebtToCompanyClearance.new(current_user, params)
    elsif params[:payment_type] == PaymentType.id_for(:reimbursement).to_s
      operation = Settlement::Payment::AddSettlement.new(current_user, params)
    end
    if operation.blank?
      respond_failure 'Error while creating payment. Unknown type'
      return
    end
    @result = operation.run
    respond(response: :success, message: success_message)
  end

  def index
    @result = Settlement::Index.(current_user, params)
    respond
  end

  def show
    @result = Settlement::Show.(current_user, params)
    respond
  end

  def summary
    @result = Settlement::Summary.(current_user, params)
    respond
    # respond_to do |format|
    #   format.json { render json: '{"success":true,"messages":{"error":[],"failure":[],"success":[],"message":[],"notice":[]},"company_card_enabled":true,"data":{"wallet":{"balance":0.0,"name":"Finly Money","id":3},"cards":[{"id":3,"name":"Expense Card","show_balance":true,"balance":278.02,"show_eligibility":true,"eligibility":9721.98,"creditable":true,"debitable":true,"active":false,"disabler":null}],"cash_on_hand":{"balance":174.41,"name":"Cash on Hand","meta":{"credit":{"base_url":"/settlements?id=3&payment_type=1"},"debit":{"base_url":"/settlements?id=3"}}},"pending_money_requests":{"balance":0.0,"count":0,"meta":{"base_url":"/settlements?id=3&payment_type=1"}},"pending_reports":{"balance":2430.48,"count":10,"reimbursement":{"associated_reimbursement_card":false,"card":{},"initiating_accounts":[{"type":"virtual_account","id":1,"name":"Company Credits","balance":null,"active":true},{"type":"wallet","id":1,"name":"Your\'s Finly Money","balance":0.0,"active":true}]},"meta":{"base_url":"/settlements?id=3&payment_type=3"}},"actions":{"meta":{"base_url":"/cards/update_balance?receiving_user_id=3&view=admin"},"credit":true,"debit":true,"credit_actions":{"initiating_accounts":[{"type":"virtual_account","id":1,"name":"Company Credits","balance":null,"active":true},{"type":"wallet","id":1,"name":"Your\'s Finly Money","balance":0.0,"active":true}],"receiving_accounts":[{"type":"wallet","id":3,"name":"Finly FinanceManager1\'s Finly Money","balance":0.0,"active":true},{"type":"card","id":3,"name":"Finly FinanceManager1\'s Expense Card","balance":278.02,"eligibility":9721.98,"show_balance":true,"show_eligibility":true,"active":false,"disabler":null}]},"debit_actions":{"initiating_accounts":[{"type":"virtual_account","id":1,"name":"Company Credits","balance":null,"active":true},{"type":"wallet","id":1,"name":"\'s Finly Money","balance":0.0,"active":true}],"receiving_accounts":[{"type":"wallet","id":3,"name":"Finly FinanceManager1\'s Finly Money","balance":0.0,"active":true},{"type":"card","id":3,"name":"Finly FinanceManager1\'s Expense Card","balance":278.02,"eligibility":9721.98,"show_balance":true,"show_eligibility":true,"active":false,"disabler":null}]}}}}' }
    # end
  end

end
