class UniqueIdentifier::Set < BaseOperation
  attr_accessor :unique_identifier

  def authorized_user_types
    [:vendor_payments_admin]
  end

  def pre_validate
    user_present? and params_present?
    return if has_errors?

    if params[:id].blank?
      add_message :error, 'Error in request'
      return
    end
  end

  def init
    purpose_id = Purpose.id_for(params[:id])
    if purpose_id.blank?
      add_message :error, 'Error in request'
      return
    end

    self.unique_identifier = user.company.unique_identifiers.with_purpose_id(purpose_id)&.first
    self.unique_identifier ||= user.company.unique_identifiers.build purpose_id: purpose_id

    self.unique_identifier.prefix = params[:prefix]
    self.unique_identifier.sequence_start = params[:sequence_start]
  end

  def validate
    unless self.unique_identifier.valid?
      add_message :error, self.unique_identifier.errors.full_messages
      return
    end
  end

  def process
    self.unique_identifier.save
  end

end