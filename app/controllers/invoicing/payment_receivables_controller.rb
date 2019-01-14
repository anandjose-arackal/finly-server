class Invoicing::PaymentReceivablesController < BaseControllers::WebBase

  before_action -> { finly_authorize! :web }

  def index
    @result = Invoicing::PaymentReceivable::Index.(current_user, params)
    respond
  end

  def create
    @result = Invoicing::PaymentReceivable::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure
    end
  end

  def destroy
    @result = Invoicing::PaymentReceivable::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure
    end
  end

  def show_transfers

  end

  def show
    @result = Invoicing::PaymentReceivable::Show.(current_user, params)
    respond
  end
end
