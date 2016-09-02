require "#{Rails.root}/app/operations/expense/manual/create"
class Api::V1::ReceiptsController < Api::V1::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!
  before_action :parse_receipt, only: [:create, :update]

  def create
    operation = Receipt::Create.new(current_user, params)
    operation.run
    if operation.is_success?
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

  def expense_from_receipt
    operation = Expense::Manual::Create.new(user, params)
    operation.run
    if operation.is_success?
      render 'api/v1/shared/success'
    else
      @errors = operation.errors
      render 'api/v1/shared/failure'
    end
  end

  def update
    operation = Receipt::Update.new(current_user, params)
    operation.run
    if operation.is_success?
      render 'api/v1/shared/success'
    else
      @errors = operation.errors
      render 'api/v1/shared/failure'
    end
  end

  private
  def parse_receipt
    params[:receipt] = {}
    params[:receipt][:image] = extract_receipt_image
  end

  def extract_receipt_image
    data = params[:receipt]
    file = data.tempfile
    file.class.class_eval { attr_accessor :original_filename, :content_type }
    file.original_filename = params[:filename]
    file.content_type = params[:content_type]
    file
  end

end
