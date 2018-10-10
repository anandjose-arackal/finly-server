module Templatable
  extend ActiveSupport::Concern

  included do
    scope :templates, -> {where.not(resource_template_id: nil)}
    scope :exclude_templates, -> {where(resource_template_id: nil)}

    belongs_to :resource_template

    accepts_nested_attributes_for :resource_template

    class_attribute :attributes_to_merge

    register_template
  end

  module ClassMethods

    def register_template
      ResourceTemplate.register(self)
    end

    def template_merge(*list)
      self.attributes_to_merge = list
    end

    def template_config(&block)
      amoeba(&block)
    end

    def templatable?
      true
    end

  end

  def templatable?
    true
  end

  def is_template?
    resource_template_id.present?
  end

end