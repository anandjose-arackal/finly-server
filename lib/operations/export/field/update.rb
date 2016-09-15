# updating an export field
# params:
#

class Export::Field::Update < Export::Base

  attr_accessor :update_params

  def init
    self.company = user.company
    self.update_params = export_params
    id = params[:id] or update_params[:export_field_id]
    self.preference = company.export_preferences.find_by(id: id)
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

  def post_process
    messages[:success] = "Export Field updated."
  end

  def success
    Export::Base::FieldPresenter.new(user, {preference: preference}, messages)
  end
end