class FinlyAdmin::CompaniesController < ApplicationController
  allow_oauth!

  before_action :authenticate_user!
  before_action :superadmin_accounts

  def new
    @states = State.all
  end

  def show
    # @result = Company::Show.(current_user, params)
    # @states = State::VALUES
    @company = Company.find_by(params[:id])
    @result = {
        balance: "35168161",
        name: "Jouska",
        d_code: "51461",
        logo: {
            url: "public/common/images/campus-layer-2.png",
            update_path: "some shit"
        }
    }
    respond_to do |format|
      format.json {
        render json: @result.as_json
      }
    end

  end

  def create
    # @result = AdminOperations::Company::Create.(current_user, params)
    # if @result.success?
    #   flash[:success] = 'Company created'
    #   redirect_to superadmin_companies_path
    # else
    #   flash[:error] = @result.messages[:error]
    #   redirect_to request.referrer
    # end


  end

  def add_admin
    @result = Company::AddAdmin.(current_user, params)
    # temporary rendering for html testing.
    if @result.success?
      flash[:success] = 'Admin Added'
      redirect_to superadmin_companies_path
    else
      flash[:error] = @result.messages[:error]
      redirect_to request.referrer
    end
  end

  def index
    @companies = Company.all
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
    unless Constants::SUPERADMIN_ACCOUNTS.include?(current_user.email)
      flash[:error] = "You are not authorized to perform this action"
      redirect_to root_url
    end
  end

end
