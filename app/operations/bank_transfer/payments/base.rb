class BankTransfer::Payments::Base < BaseOperation

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end
end