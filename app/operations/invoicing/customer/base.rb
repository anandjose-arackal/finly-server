class Invoicing::Customer::Base < BaseOperation

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def validate

  end
end