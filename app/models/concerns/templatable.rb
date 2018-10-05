module Templatable
  extend ActiveSupport::Concern

  included do
    default_scope {where(is_deleted: [false, nil])}
    scope :templates, -> {where(is_template: true)}
    scope :exclude_templates, -> {where(is_template: [false, nil])}

    class_attribute :attributes_to_merge
    # cattr_accessor
  end

  module ClassMethods

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

end