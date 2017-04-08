class FinlyAdmin::CompaniesController < ApplicationController
  allow_oauth!

  before_action :authenticate_user!
  # before_action :superadmin_accounts

  def new
    @states = State.all
  end

  def show
    @result = AdminOperations::Company::Show.(current_user, params)
  end

  def create
    @result = AdminOperations::Company::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
  end
  end

  def index
    @companies = Company.all
    respond_to do |format|
      format.json {
        render json: @companies.as_json
      }
    end
  end

  def update
    @result = Superadmin::Company::Update.(current_user, params)
    if @result.success?
      flash[:success] = "Company updated"
    else
      flash[:error] = @result.messages[:error]
    end
    redirect_to request.referrer
  end

  def import
    import_op = Import::Superadmin::Users.new(current_user, params)
    @result = import_op.run
    respond_to do |format|
      format.csv { send_data @result, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment;data=result.csv" }
    end
  end


  private

  def superadmin_accounts
    unless current_user.company.name == "Jouska"
      redirect_to root_url
    end
  end

end
