# == Schema Information
#
# Table name: form_choice_dependencies
#
#  id                    :bigint           not null
#  uuid                  :string(36)       not null, primary key
#  company_id            :bigint           not null
#  form_id               :string(36)       not null
#  dependent_entity_id   :string(36)       not null
#  controlling_entity_id :string(36)       not null
#  dependency_id         :string(255)
#  custom                :boolean
#  is_updated            :boolean
#  can_be_updated        :boolean
#  created_by_id         :integer
#  updated_by_id         :integer
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class FormChoiceDependency < ApplicationRecord
  include UUIDHelper, TemplateClonable

  belongs_to :company
  belongs_to :form
  belongs_to :controlling_entity, class_name: "FormEntity"
  belongs_to :dependent_entity, class_name: 'FormEntity'
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  # has_many :rules, class_name: 'FormRule', as: :rule_parent
  has_many :mappings, class_name: 'FormChoiceDependencyMapping', foreign_key: :dependency_id

  def as_json(options = {})
    data = {}

  end

  def self.system_dependency(params, &block)
    params[:custom] = false
    params[:internal] ||= false
    params[:is_updated] = false
    params[:can_be_updated] ||= false
    dependency = self.new(params)
    dependency.instance_eval &block if block_given?
    if dependency.dependency_id.blank?
      raise "Dependency ID cannot be blank for #{dependency}"
    end
    dependency
  end

  def reference(controller:, dependent:)
    template_reference[:controlling_entity_path] = controller
    template_reference[:dependent_entity_path] = dependent
  end

  def dependency(controlling_choice, dependent_choice)
    dependent_choice = [dependent_choice] unless dependent_choice.respond_to?(:each)
    dependent_choice.each do |dep_ch|
      mapping = mappings.new
      mapping.reference(controlling_choice, dep_ch)
    end
    mappings
  end

end
