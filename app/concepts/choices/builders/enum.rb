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

  def choice_records(params: {}, user: nil)
    filtered_list = params.dig(:q, :id_in)&.map(&:to_i)
    records = klass.all
    records = records.where(id: filtered_list) unless filtered_list.nil?
    records
  end

  def choices(params: {}, user: nil)
    list = []
    choice_records(params: params, user: user).each do |item|
      list << {
          id: item.send(id),
          name: item.name&.titleize,
      }
    end
    list
  end

  # def choices_json(params: {}, user: nil)
  #   choices(params: {}, user: nil).as_json
  # end

  def find_by_id(id, params: {}, user: nil)
    rec = choice_records(params: params, user: user).where(id: id).first
    return unless rec

    {
      id: rec.id,
      name: rec.name&.titleize,
    }
  end

  def find_by_name(name, params: {}, user: nil)
    rec = choice_records(params: params, user: user).where('LOWER(name) LIKE LOWER(?)', name).first
    return unless rec

    {
      id: rec.id,
      name: rec.name&.titleize,
    }
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