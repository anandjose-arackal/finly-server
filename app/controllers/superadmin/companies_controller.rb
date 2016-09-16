class Superadmin::CompaniesController < ApplicationController

  before_action :authenticate_user!
  before_action :check_superadmin

  def new

  end

  def show
    @company = Company.find_by(id: params[:id])
  end

  def create
    @company = Company.create!(company_params)
    @admin = @company.users.build(admin_params)
    if @company.save && @admin.save
      @admin.activate
      redirect_to request.referrer
    else
      flash.now[:danger] = "Adding new company failed. Please try again."
      redirect_to request.referrer
    end
  end

  def add_admin
    @company = Company.find_by(id: params[:company_id])
    @admin = @company.users.build(admin_params)
    if @admin.save
      @admin.activate
      redirect_to request.referrer
    else
      flash.now[:danger] = "Unable to add admin"
      redirect_to request.referrer
    end
  end

  def index
    @companies = Company.all
  end

  private

  def admin_params
    params[:admin][:role_mapping_attributes] = [{user_role_id: UserRole.admin_id},
                                            {user_role_id: UserRole.employee_id}]

    params.require(:admin).permit(:name, :email, :password, :password_confirmation,
                                  :mobile_number, team_mapping_attributes: [:default], role_mapping_attributes: [:user_role_id])
  end

  def company_params
    params.require(:company).permit(:name)
  end

  def check_superadmin
    unless Constants::SUPERADMIN_ACCOUNTS.include?(current_user.email)
      redirect_to root_url
    end
  end

end
