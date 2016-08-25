# updating an export field

class Export::Field::Update < Export::Base

  attr_accessor :update_params

  def init
    self.company = user.company
    self.update_params = export_params
    self.preference = company.export_preferences.find_by(id: update_params[:export_field_id])
  end

  def validate
    unless preference
      errors << "Cannot find preference to update."
      return false
    end
    if update_params.blank?
      errors << "Nothing to update."
    end
  end

  def process
    unless preference.update(update_params)
      errors << preference.errors.full_messages
    end
  end

end