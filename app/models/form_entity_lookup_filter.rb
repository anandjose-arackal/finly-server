class FormEntityLookupFilter < ApplicationRecord
  include TemplateClonable, UUIDHelper

  belongs_to :company
  belongs_to :form
  belongs_to :form_entity
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  serialize :rule, Forms::Rules::Ransack

  def self.system_lookup_filter(params = {}, &block)
    params[:custom] = false
    params[:internal] ||= false
    params[:is_updated] = false
    params[:can_be_updated] ||= false
    lookup_filter = self.new(params)
    lookup_filter.instance_eval &block if block_given?
    if lookup_filter.filter_id.blank?
      raise 'Filter ID cannot be blank'
    end
    lookup_filter
  end

  def reference(entity_path)
    template_reference[:entity_path] = entity_path
  end

  def rule_builder
    @rule_builder ||= Forms::Rules::Builder.new
  end

  def rule(rule=NoObject)
    self.rule = rule unless rule == NoObject
    super()
  end

end
