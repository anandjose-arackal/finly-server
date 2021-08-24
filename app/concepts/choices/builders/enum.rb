class Choices::Builders::Enum < Choices::Builders::Base

  register! :enum

  def self.call(klass, id: :id, name: :name)
    self.new({enum: klass.to_s, id: id, name: name})
  end

  def klass
    Object.const_get(config[:enum].to_s)
  end

  def id
    config[:id]
  end

  def name
    config[:name]
  end

  def choices(params: {}, user: nil)
    list = []
    filtered_list = params.dig(:q, :id_in)&.map(&:to_i)
    records = klass.all
    records = records.where(id: filtered_list) unless filtered_list.nil?
    records.each do |item|
      list << {
          id: item.send(id),
          name: item.send(name).titleize,
      }
    end
    list
  end

  # def choices_json(params: {}, user: nil)
  #   choices(params: {}, user: nil).as_json
  # end

  def find_by_id(id, params: {}, user: nil)
    choices(params: params, user: user).find {|item| item[:id] == id}
  end

  def find_by_name(name, params: {}, user: nil)
    choices(params: params, user: user).where(name: name).first
  end

  def build(params: {}, user: {})
    list = []
    klass.all.each do |item|
      list << {
          id: item.send(id),
          name: item.send(name).titleize,
      }
    end

    Choices::Provider.new(provider: self, partial: false, data: choices(params: params, user: user))
  end

end