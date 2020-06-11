# == Schema Information
#
# Table name: form_sections
#
#  id                      :bigint           not null
#  uuid                    :string(36)       not null, primary key
#  section_id              :string(255)      not null
#  form_id                 :string(36)       not null
#  company_id              :integer          not null
#  active                  :boolean          default(TRUE)
#  deleted_at              :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  associate_custom_fields :boolean          default(FALSE)
#  title                   :string(255)
#

class FormSection < ApplicationRecord
  include UUIDHelper, SoftDeletable
  include Forms::Entity::Registry

  belongs_to :company
  belongs_to :form
  has_many :entities, class_name: 'FormEntity', dependent: :destroy

  def section
    self
  end

  # Fixme: Delete this as it is available in Forms::Entity::Registry. Kept it commented for testing purpose
  # def find_entity(entity_path)
  #   entities.each do |entity|
  #     return entity if entity.entity_path == entity_path
  #
  #     entity.find_entity(entity_path)
  #   end
  # end

  def as_json(options = {})
    data = {
        title: title,
        active: active,
        config_path: section_id.to_s,
        entities: {}
    }
    entities.exclude_internal.root.each do |ent|
      data[:entities][ent.entity_key] = ent.as_json(options.merge(config_path: "#{section_id}/entities"))
    end
    data
  end
end
