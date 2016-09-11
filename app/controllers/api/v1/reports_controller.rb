# Dir[File.expand_path "app/lib/operations/**/*.rb"].each{|f| require_relative(f)}
require "#{Rails.root}/lib/operations/report/comment/create"
class Api::V1::ReportsController < Api::V1::BaseApiController
  include MathUtil
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  respond_to :json

  def create
    operation = Report::Create.new(current_user, params)
    @result = operation.run
    if operation.is_success?
      render 'api/v1/reports/show'
      return
    end
    @errors = operation.errors
    render 'api/v1/shared/failure'
  end

  def index
    operation = Report::Index.new(current_user, params)
    @result =operation.run
    if operation.is_success?
      render 'api/v1/reports/index'
    else
      @errors = operation.errors
      render 'api/v1/shared/failure'
    end
  end

  def update
    updater = Report::Update.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      render 'api/v1/reports/show'
    else
      @errors = updater.errors
      render 'api/v1/shared/failure'
    end
  end

  def show
    @result = Report::Show.(current_user, params)
  end

  def destroy
    updater = Report::Destroy.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      flash.now[:success] = 'Report Deleted'
      render 'api/v1/shared/success'
    else
      @errors = updater.errors
      render 'api/v1/shared/failure'
    end
  end

  def add_expenses
    updater = Report::Expenses::Add.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      render 'api/v1/reports/show'
    else
      @errors = updater.errors
      render 'api/v1/shared/failure'
    end
  end

  def remove_expenses
    updater = Report::Expenses::Remove.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      render 'api/v1/reports/show'
    else
      @errors = updater.errors
      render 'api/v1/shared/failure'
    end
  end

  def reject_expense
    updater = Report::Expenses::Reject.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      render 'api/v1/reports/show'
    else
      @errors = updater.errors
      render 'api/v1/shared/failure'
    end
  end

  def submit
    updater = Report::Submit.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      render 'api/v1/reports/show'
    else
      @errors = updater.errors
      render 'api/v1/shared/failure'
    end
  end

  def retract
    updater = Report::Retract.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      render 'api/v1/reports/show'
    else
      @errors = updater.errors
      render 'api/v1/shared/failure'
    end
  end

  def approve
    updater = Report::Approve.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      render 'api/v1/reports/show'
    else
      @errors = updater.errors
      render 'api/v1/shared/failure'
    end
  end

  def reject
    updater = Report::Reject.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      render 'api/v1/reports/show'
    else
      @errors = updater.errors
      render 'api/v1/shared/failure'
    end
  end

  def unapprove
    updater = Report::Unapprove.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      render 'api/v1/reports/show'
    else
      @errors = updater.errors
      render 'api/v1/shared/failure'
    end
  end

  def take_control
    updater = Report::Submit.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      flash.now[:success] = 'You have successfully taken control of the report'
      render 'api/v1/reports/show'
    else
      @errors = updater.errors
      render 'api/v1/shared/failure'
    end
  end

  def reimbursement_confirm
    updater = Report::ReimburseConfirm.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      render 'api/v1/reports/show'
    else
      @errors = updater.errors
      render 'api/v1/shared/failure'
    end
  end

  def comment
    updater = Report::Comment::Create.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      render 'api/v1/reports/show'
    else
      @errors = updater.errors
      render 'api/v1/shared/failure'
    end
  end

end
