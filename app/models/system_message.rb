# == Schema Information
#
# Table name: system_messages
#
#  id                     :integer          not null, primary key
#  content                :text(65535)      not null
#  system_message_type_id :integer          not null
#  messagable_id          :integer
#  messagable_type        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_deleted             :boolean          default(FALSE)
#  type                   :string(255)
#

class SystemMessage < ActiveRecord::Base
  include SoftDeletable

  belongs_to :system_message_type
  belongs_to :messagable, polymorphic: true

  def as_json(options={})
    {type: {id: system_message_type.id,
            name: system_message_type.name},
     content: content}
  end

  scope :errors, -> {where system_message_type_id: SystemMessageType.id_for(:error)}
  scope :info, -> {where system_message_type_id: SystemMessageType.id_for(:info)}

  scope :aadhar_card_messages, -> {where type: "aadhar_card"}
  scope :certificate_of_registration_messages, -> {where type: "certificate_of_registration"}
  scope :registration_of_trust_messages, -> {where type: "registration_of_trust"}
  scope :pan_card_messages, -> {where type: "pan_card"}
  scope :vat_registration_certificate_messages, -> {where type: "vat_registration_certificate"}
  scope :certificate_of_registration_messages, -> {where type: "certificate_of_registration"}
  scope :coi_messages, -> {where type: "coi"}
end
