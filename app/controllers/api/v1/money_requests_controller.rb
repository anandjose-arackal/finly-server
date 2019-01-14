class Api::V1::MoneyRequestsController < Api::V1::BaseApiController
  protect_from_forgery with: :null_session



  respond_to :json

  def create
    Formatter.handle_api_nil(params)
    @result = MoneyRequest::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/money_requests/show'
    else
      respond response: :failure
    end
  end

  def index
    @result = MoneyRequest::Index.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def show
    @result = MoneyRequest::Show.(current_user, params)
    @result.config[:mobile_api] = true
    respond render: :show
  end

  def update
    Formatter.handle_api_nil(params)
    # fail
    if params[:type].blank?
      respond_failure 'Invalid update type'
      return
    end
    case params[:type].to_sym
     when :update
        @result = MoneyRequest::Update.(current_user, params)
      when :submit
        @result = MoneyRequest::Submit.(current_user, params)
      when :retract
        @result = MoneyRequest::Retract.(current_user, params)
      when :approve
        @result = MoneyRequest::Approve.(current_user, params)
      when :reject
        @result = MoneyRequest::Reject.(current_user, params)
      when :unapprove
        @result = MoneyRequest::Unapprove.(current_user, params)
      when :credit
        # from_account: wallet / virtual_account
        @result = MoneyRequest::PrepaidCard::Credit.(current_user, params)
      when :approve_and_forward_to
        @result = MoneyRequest::ApproveAndForward.(current_user, params)
      when :take_control
        @result = MoneyRequest::TakeControl.(current_user, params)
    end
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/money_requests/show'
    else
      respond response: :failure
    end
  end

  def credit_cash
    @result = MoneyRequest::Cash::Credit.(current_user, params)
    respond
  end

  def destroy
    @result = MoneyRequest::Destroy.(current_user, params)
    @result.config[:mobile_api] = true
    respond response: :success
  end

  def comment
    if params[:content].present? and (params[:content] == "" or params[:content] == 'nil')
      params[:content] = nil
    end
    @result = MoneyRequest::Comment::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/money_requests/show'
    else
      respond response: :failure
    end
  end

end
