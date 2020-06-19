class Lookup::Attribute

  attr_accessor :id, :label, :visible, :includes, :primary, :value

  def initialize(params)
    params.each_pair do |key, value|
      self.send("#{key}=", value)
    end
    self.label ||= id.to_s.titleize
    self.visible = true if self.visible.nil?
    self.primary = false if self.primary.nil?
    self.value ||= id
  end

  def as_json(options={})
    {
        column: id,
        label: label,
        visible: visible,
        primary: primary
    }
  end

end