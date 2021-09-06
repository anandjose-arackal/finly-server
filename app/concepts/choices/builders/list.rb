class Choices::Builders::List < Choices::Builders::Base

  register! :list

  def self.call(*args)
    self.new({choices: args&.map {|m| m.slice(:id, :name, :active)}})
  end

  def choices(params: {}, user: nil, entity: nil)
    if self.entity&.choices_scope&.config&.dig("choices").present? || config&.dig("choices").present? || config&.dig(:choices).present?
      config[:choices]
    else
      data = self.entity&.choices
      return data&.where(uuid: params.dig(:q)&.dig(:id_in)) if params.dig(:q)&.dig(:id_in).is_a?(Array)
      data
    end
  end

  def find_by_id(id, params: {}, user: nil)
    list = choices(params: params, user: user)
    if list.respond_to?(:find_by)
      list.find_by(uuid: id)
    elsif list.respond_to?(:filter)
      (list.filter do |item|
        item[:id] == id || item["id"] == id || item[:uuid] == id || item["uuid"] == id
      end).first
    end
  end

  def find_by_name(name, params: {}, user: nil)
    list = choices(params: params, user: user)
    if list.respond_to?(:find_by)
      list.find_by(name: name)
    elsif list.respond_to?(:filter)
      (list.filter do |item|
        (item[:name]&.downcase == name&.downcase) || (item["name"]&.downcase == name&.downcase)
      end).first
    end
  end

  def build(params: {}, user: nil)
    # Todo: Allow partial list based on the size of the choices
    Choices::Provider.new(provider: self, partial: false, data: choices(params: params, user: user))
  end

end