class RateContracts::Base < BaseOperation
  attr_accessor :rate_contract
  def authorized_user_types
    [:employee]
  end

  def pre_validate
    unless user.present? && params.present?
      add_message :error, 'Invalid Request'
    end
  end
end