# == Schema Information
#
# Table name: form_entities
#
#  id                           :bigint           not null
#  uuid                         :string(36)       not null, primary key
#  company_id                   :integer          not null
#  form_id                      :string(36)       not null
#  form_section_id              :string(36)       not null
#  created_by_user_id           :integer
#  entity_key                   :string(255)      not null
#  label                        :string(255)
#  placeholder                  :string(255)
#  hint                         :string(255)
#  entity_type                  :string(255)
#  default_value                :string(255)
#  editable                     :boolean
#  required                     :boolean
#  active                       :boolean
#  unique                       :boolean
#  visible                      :boolean
#  position                     :integer
#  custom_field                 :boolean
#  can_visible_be_changed       :boolean
#  can_editable_be_changed      :boolean
#  can_required_be_changed      :boolean
#  can_uniqueness_be_changed    :boolean
#  can_be_disabled              :boolean
#  can_label_be_renamed         :boolean
#  can_choices_be_changed       :boolean
#  allow_clearing_default_value :boolean
#  options                      :text(65535)
#  deleted_at                   :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  choices_scope                :text(65535)
#  internal                     :boolean          default(FALSE)
#  is_modified                  :boolean          default(FALSE)
#  entity_path                  :string(255)
#  parent_id                    :string(255)
#  populate_if_empty            :string(255)
#  type                         :string(255)
#  config                       :text(65535)
#  associate_custom_fields      :boolean
#  compute                      :boolean
#  compute_enabled              :boolean
#  compute_type_id              :integer
#  compute_formula              :string(255)
#  compute_lookup_entity_id     :string(255)
#  filters                      :text(65535)
#

class FormEntity::Attachment < FormEntity

  FORMAT = %w(txt pdf doc docx xls xlsx).freeze

  register :attachment
  collection!

  option :maximum, default: 255
  option :minimum, default: 0
  option :format, default: FORMAT

  # operators :eq_any, :not_eq_all, :cont_any, :not_cont_all, :blank, :present

  contract_eval 'Max Items Check', &Forms::Validations::Templates[:maximum]
  contract_eval 'Min Items Check', &Forms::Validations::Templates[:minimum]

  schema_validation do
    required(:options) do
      hash do
        required(:maximum).value(:int?, lteq?: 255)
        required(:minimum).value(:int?, gteq?: 0)
        optional(:format).each(included_in?: FORMAT)
      end
    end
  end

  # def populator
  #   -> (model: nil, collection:, fragment: nil, index: nil, options:, **) do
  #     id = (fragment["id"] || fragment[:id] || fragment["uuid"] || fragment[:uuid]).to_s
  #     item = collection.find { |item| id == item.id.to_s }
  #
  #     if fragment["_destroy"]
  #       collection.destroy(item) if item
  #       return skip!
  #     end
  #
  #     item ? item : collection.append(::Attachment.find(id))
  #   end
  # end

  def self.option_validation
    Proc.new do
      validation :options_config do
        params do
          required(:options) do
            hash do
              required(:maximum).value(:int?, lteq?: 255)
              required(:minimum).value(:int?, gteq?: 0)
              optional(:format).each(included_in?: FORMAT)
            end
          end
        end
      end
    end
  end
end
