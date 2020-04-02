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

    if params.present? and not params.is_a?(Hash)
      raise "Invalid field params #{params}"
    end

    params.each_pair do |key, value|
      next if value.nil?
      send :"#{ key }=", value
    end
  end

  def content_type
    self.class.content_type
  end

  def build(context, user, record, exposure)
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
          value = context.send(retriever, user, record, exposure)
        else
          value = exposure.send(retriever)
        end
      else
        value = retriever
      end
      data[attribute[:name]] = value
    end
    data
  end

end