class Admin::Companies::Update < Admin::Companies::Base

  attr_accessor :company, :company_update_params

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.company = Company.find_by(id: params[:id])
    self.company_update_params = company_params
    if company_update_params[:itz_cash_property_attributes].present? && company_update_params[:itz_cash_property_attributes][:d_code].present?
      if company.itz_cash_property.present? # if the company has been signed up with the pre paid cards
        company_update_params[:itz_cash_property_attributes][:id] = company.itz_cash_property.id
      end
    end
  end

  def validate
    if company.blank?
      add_message :error, "Company not found"
    end
  end

  def process
    unless company.update(company_update_params)
      add_message :error, company.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Company updated"
  end


end