class Export::Base < BaseOperation

  attr_accessor :company, :preference


  def authorized_user_types
    [:admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      errors << "User or parameters not present."
    end
  end

  def export_params
    params.require(:export).permit(:export_field_id, :name)
  end

  def retrieve
    if is_success?
      self.preference
    else
      false
    end
  end


end