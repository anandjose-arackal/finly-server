require "#{Rails.root}/lib/operations/expense/manual/create"
class Api::V1::ReceiptsController < Api::V1::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  def create
    RequestFormatter.parse_receipt(current_user, params)
    operation = Receipt::Create.new(current_user, params)
    operation.run
    if operation.success?
      render 'api/v1/shared/success'
    else
      @errors = operation.errors
      render 'api/v1/shared/failure'
    end
  end

  def index
    @result = Receipt::Index.(current_user, params)
  end

  def destroy
    operation = Receipt::Destroy.new(current_user, params)
    if operation.run
      render 'api/v1/shared/success'
    else
      @errors = operation.errors
      render 'api/v1/shared/failure'
    end
  end

  def update
    operation = Receipt::Update.new(current_user, params)
    operation.run
    if operation.success?
      render 'api/v1/shared/success'
    else
      @errors = operation.errors
      render 'api/v1/shared/failure'
    end
  end

end
