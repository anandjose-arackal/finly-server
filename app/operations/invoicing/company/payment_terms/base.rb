class Invoicing::Company::PaymentTerms::Base < Invoicing::Company::Base

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def payment_term_params
    params.require(:payment_term).permit(:name, :days_after, :description)
  end
end