# updating an export field
# params:
#

class Export::Field::Update < Export::Base

  attr_accessor :update_params

  def init
    self.company = user.company
    self.update_params = export_params
    self.preference = company.export_preferences.find_by(id: update_params[:export_field_id])
  end

  def authorize
    unless preference
      raise_unauthorized_exception
    end
  end

  def validate
    if update_params.blank?
      messages[:error] << "Nothing to update."
    end
  end

  def process
    unless preference.update(update_params)
      messages[:error] << preference.errors.full_messages
    end
  end

  def success
    Export::Base::FieldPresenter.new(user, {preference: preference})
  end
end