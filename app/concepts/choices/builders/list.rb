class Choices::Builders::List < Choices::Builders::Base

  register! :list

  def self.call(*args)
    self.new({choices: args&.map {|m| m.slice(:id, :name, :active)}})
  end

  def choices(params: {}, user: nil, form_entity: nil)
    if self.form_entity&.choices_scope&.config&.dig("choices").present? || config.present?
      config[:choices]
    else
      data = self.form_entity&.choices
      return data&.where(uuid: params.dig(:q)&.dig(:id_in)) if params.dig(:q)&.dig(:id_in).is_a?(Array)
      data
    end
  end

  def find_by_id(id, params: {}, user: nil)
    choices(params: params, user: user).find_by(uuid: id)
  end

  def find_by_name(name, params: {}, user: nil)
    choices(params: params, user: user).find_by(name: name)
  end

  def build(params: {}, user: nil)
    # Todo: Allow partial list based on the size of the choices
    Choices::Provider.new(provider: self, partial: false, data: choices(params: params, user: user))
  end

end