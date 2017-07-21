class Admin::Companies::Show < Admin::Companies::Base

  attr_accessor :company

  def init
    self.company = Company.find_by(id: params[:id])
  end

  def validate
    if company.blank?
      add_message :error, "Company not found"
    end
  end

  def kyc_actions
  end

end