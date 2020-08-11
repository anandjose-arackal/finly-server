class Exposures::FakeExposure < Exposures::API
  attr_accessor :exposure_klass, :all_includes

  def initialize(exposure_klass)
    self.exposure_klass = exposure_klass
    self.all_includes = []
  end

  # use method_missing to capture includes
  # TODO: need to extend this to get nested includes
  def method_missing(m, *args, &block)
    attribute = exposure_klass.attributes[m.to_sym]
    1 unless attribute.present?
    self.all_includes += attribute.includes
    1
  end

  # Override Liquid::Drop invokable? method to capture required fields in method_missing method.
  def self.invokable?(method_name)
    true
  end
end