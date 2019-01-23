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
#  message_type           :string(255)
#  deleted_at             :datetime
#

class SystemMessage < ApplicationRecord
  include SoftDeletable

  belongs_to :system_message_type, optional: true
  belongs_to :messagable, optional: true, polymorphic: true

  scope :errors, -> {where system_message_type_id: SystemMessageType.id_for(:error)}
  scope :info, -> {where system_message_type_id: SystemMessageType.id_for(:info)}

  scope :aadhar_card_messages, -> {where message_type: "aadhar_card"}
  scope :certificate_of_registration_messages, -> {where message_type: "certificate_of_registration"}
  scope :registration_of_trust_messages, -> {where message_type: "registration_of_trust"}
  scope :pan_card_messages, -> {where message_type: "pan_card"}
  scope :vat_registration_certificate_messages, -> {where message_type: "vat_registration_certificate"}
  scope :certificate_of_registration_messages, -> {where message_type: "certificate_of_registration"}
  scope :certificate_of_incorporation_messages, -> {where message_type: "certificate_of_incorporation"}
  scope :id_proof_messages, -> {where message_type: "id_proof"}
  scope :address_proof_messages, -> {where message_type: "address_proof"}
  scope :supporting_document_messages, -> {where message_type: "supporting_document"}
  scope :list_of_partners_messages, -> {where message_type: "list_of_partners"}
  scope :list_of_partners_din_messages, -> {where message_type: "list_of_partners_din"}
  scope :partnership_deed_messages, -> {where message_type: "partnership_deed"}
  scope :trust_deed_messages, -> {where message_type: "trust_deed"}
  scope :list_of_trustees_karta_messages, -> {where message_type: "list_of_trustees_karta"}

  def as_json(options={})
    {type: {id: system_message_type.id,
            name: system_message_type.name},
     content: content}
  end

end
