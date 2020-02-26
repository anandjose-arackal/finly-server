class IndexBuilder::ContentTypes::Base
  include DynamicAttributes

  attr_accessor :params
  class_attr :content_type

  def self.register(type)
    self.content_type(type)

    IndexBuilder::ContentTypes::Registry.register(type, self)
  end

  def self.attribute(name, default: nil)
    attributes << {name: name, default: default}
    attr_accessor name
  end

  def self.attributes
    @attributes ||= []
  end

  def self.call(params)
    self.new(params)
  end

  def initialize(params)
    self.params = params

    params.each_pair do |key, value|
      next if value.nil?
      send :"#{ key }=", value
    end
  end

  def content_type
    self.class.content_type
  end

  def build(context, user, exposure)
    data = {content_type: content_type}
    self.class.attributes.each do |attribute|
      value = nil
      retriever = send(attribute[:name]) || attribute[:default]

      if retriever.is_a?(Proc)
        retriever = instance_exec &retriever
      end

      if retriever.is_a?(String)
        value = exposure.template(retriever)
      elsif retriever.is_a?(Symbol)
        if context.respond_to?(retriever)
          value = context.send(retriever, user, exposure)
        else
          value = exposure.send(retriever)
        end
      else
        value = retriever
      end
      data[attribute[:name]] = format(value)
    end
    data
  end

  def format(value)
    # case value.class.to_s
    # when "ActiveSupport::TimeWithZone", "DateTime"
    #   value.strftime "%I:%M %p, %d-%b-%Y"
    # when "Date"
    #   value.strftime "%d-%b-%Y"
    # else
    value&.to_s
    # end
  end

end