class Transcriber::ExpensesController < BaseControllers::AdminBase



  def create
    @result = Transcriber::Expenses::Create.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = Transcriber::Expenses::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show

  end

  def update
    @result = Transcriber::Expenses::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def currencies
    currencies = Currency.all
    render json: currencies.as_json
  end
end
