class Mobile::V2::ReportsController < BaseControllers::MobileBase

  include MathUtil
  protect_from_forgery with: :null_session



  respond_to :json

  def create
    @result = Reports::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v2/reports/show'
    else
      respond response: :failure
    end
  end

  def update
    action = (params[:action_type] or :update)
    @result = nil
    case action.to_sym
      when :submit
        @result = Reports::Submit.(current_user, params)
      when :retract
        @result = Reports::Retract.(current_user, params)
      when :approve
        @result = Reports::Approve.(current_user, params)
      when :reject
        @result = Reports::Reject.(current_user, params)
      when :unapprove
        @result = Reports::Unapprove.(current_user, params)
      when :add_expenses
        @result = Reports::Expenses::Add.(current_user, params)
      when :remove_expenses
        @result = Reports::Expenses::Remove.(current_user, params)
      when :reimbursement_confirm
        @result = Reports::SettlementConfirm.(current_user, params)
      when :reject_expense
        @result = Reports::Expenses::Reject.(current_user, params)
      else
        @result = Reports::Update.(current_user, params)
    end
    if @result.present?
      @result.config[:mobile_api] = true
      if @result.success?
        respond render: 'mobile/v2/reports/show'
        return
      end
    end
    respond response: :failure
  end

  def show
    @result = Reports::Show.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def destroy
    @result = Reports::Destroy.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond response: :success
    else
      respond response: :failure
    end
  end

  def comment
    if params[:content].present? and (params[:content] == "" or params[:content] == 'nil')
      params[:content] = nil
    end
    @result = Reports::Comment::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v2/reports/show'
    else
      respond response: :failure
    end
  end

end
