class IndexBuilder::Templates::Base
  include DynamicAttributes

  class_attr :handle

  def self.call(params)
    self.new(params)
  end

  def self.fields
    @fields ||= []
  end

  def self.field(name)
    fields << name
    attr_accessor name
  end

  def initialize(params)
    params.each_pair do |key, value|
      next if value.nil?
      send :"#{ key }=", value
    end
  end

  def handle
    self.class.handle
  end

  def build(user, exposure)
    data = {}
    self.class.fields.each do |field|
      value = nil
      retriever = send(field)
      if retriever.is_a?(String)
        value =  exposure.template(retriever)
      elsif retriever.is_a?(Symbol)
        if respond_to?(retriever)
          value = send(retriever)
        else
          value = exposure.send(retriever)
        end
      end
      data[field] = format(value)
    end
    data
  end

  def format(value)
    case value.class.to_s
    when "ActiveSupport::TimeWithZone", "DateTime"
      value.strftime "%I:%M %p, %d-%b-%Y"
    when "Date"
      value.strftime "%d-%b-%Y"
    else
      value
    end
  end

end