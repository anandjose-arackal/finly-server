class TaxRates::Base < BaseOperation

  attr_accessor :company

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def tax_rate_params
    params.require(:tax_rate).permit(:name, :rate, :sgst_internal_id, :cgst_internal_id, :igst_internal_id)
  end
end