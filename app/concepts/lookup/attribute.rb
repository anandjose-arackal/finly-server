class Lookup::Attribute

  attr_accessor :id, :label, :value, :visible, :includes

  def initialize(params)
    params.each_pair do |key, value|
      self.send("#{key}=", value)
    end
    self.label ||= id.to_s.titleize
    self.value ||= id
  end

  def config
    {
        id: id,
        label: label,
        visible: visible
    }
  end

end