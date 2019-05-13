class UniqueIdentifier::Index < BaseOperation

  class UniqueIdentifier::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :unique_identifiers

    def init
      self.unique_identifiers = params[:unique_identifiers]&.include_for_index
    end

    def get(purpose_name)
      self.unique_identifiers.each do |unique_identifier|
        return unique_identifier if unique_identifier.purpose.name.to_s == purpose_name.to_s
      end
      nil
    end

  end

  attr_accessor :unique_identifiers

  def authorized_user_types
    [:vendor_payments_admin]
  end

  def pre_validate
    user_present? and params_present?
  end

  def init
    self.unique_identifiers = user.company.unique_identifiers
  end

  def success
    params[:unique_identifiers] = self.unique_identifiers
    UniqueIdentifier::Index::SuccessPresenter.new(user, params, messages)
  end

end