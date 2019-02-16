class MoneyRequestController < ApplicationController

  before_action -> { finly_authorize! :web}

  def create
    @result = MoneyRequests::Create.(current_user, params)
    respond render: :show
  end

  def index
    @result = MoneyRequests::Index.(current_user, params)
    respond
  end

  def show
    @result = MoneyRequests::Show.(current_user, params)
    respond render: :show
  end

  # params[:type] = types given below
  def update
    # fail
    if params[:action_type].blank?
      respond_failure 'Invalid update type'
      return
    end
    case params[:action_type].to_sym
      when :update
        @result = MoneyRequests::Update.(current_user, params)
      when :submit
        @result = MoneyRequests::Submit.(current_user, params)
      when :retract
        @result = MoneyRequests::Retract.(current_user, params)
      when :approve
        @result = MoneyRequests::Approve.(current_user, params)
      when :reject
        @result = MoneyRequests::Reject.(current_user, params)
      when :unapprove
        @result = MoneyRequests::Unapprove.(current_user, params)
      when :credit
        # from_account: wallet / virtual_account
        @result = MoneyRequests::PrepaidCard::Credit.(current_user, params)
      when :approve_and_forward_to
        @result = MoneyRequests::ApproveAndForward.(current_user, params)
      when :take_control
        @result = MoneyRequests::TakeControl.(current_user, params)
    end
    respond render: :show
  end

  def credit_cash
    @result = MoneyRequests::Cash::Credit.(current_user, params)
    respond
  end

  def destroy
    @result = MoneyRequests::Destroy.(current_user, params)
    respond response: :success
  end

  def comment
    @result = MoneyRequests::Comment::Create.(current_user, params)
    respond render: :show
  end

  def config_details
    @result = MoneyRequests::Config.(current_user, params)
    respond
  end

  protected
  def respond(item=nil)
    if @result.failure?
      super()
    else
      super(item)
    end
  end
end
