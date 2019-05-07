class OrganizationAccount::Configuration::Base < BaseOperation

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
  end

  def validate
    unless user.vendor_payments_admin?
      add_message :error, 'You are not authorized to take this action'
    end
  end
end