class PaymentAgreementIndex < Searchkick::Api::DSL

  scope do
    includes(:policy, :status, :created_by)
  end

  record_type 'payment_agreements'

  field :policy_id, value: ->(record) { record.policy_id }, searchable: false, displayable: false
  field :policy_name, value: ->(record) { record.policy&.name }
  field :status_id, value: ->(record) { record.status&.id }, searchable: false, displayable: false
  field :status_name, value: ->(record) { record.status&.name&.titleize }
  field :sequence_id, value: ->(record) { record.order_number }
  field :description, value: ->(record) { record.title }
  field :narration, value: ->(record) { record.note }

  # included do
  #   scope :searchkick_import, -> {
  #     includes(:policy, :status, :created_by)
  #   }
  #
  #   searchkick_record_type :payment_agreements
  # end
  #
  # def searchkick_data
  #   {
  #       policy_id: policy_id,
  #       policy_name: policy&.name,
  #       status_id: status&.id,
  #       status_name: status&.name&.titleize,
  #       sequence_id: order_number,
  #       description: title,
  #       narration: note,
  #   }
  # end

  # index Indexes::Vp do
  #   include_associations :policy, :status, :created_by, Indexes::Vp::Helpers::INCLUDE_COLLABORATORS
  #
  #   document_type :payment_agreements
  #   features :agreement_based_payment_system
  #   permissions Docs::P2P::Agreements::Index.permissions
  #   category :masters
  #   route 'agreements/{{record_id}}/params={}'
  #   layout(
  #       {
  #           fixed_left: [:description, :sequence_id],
  #           fixed_right: [:created_by_name, :created_by_email, :status_name]
  #       }
  #   )
  #
  #   serialize do |record|
  #     {
  #         policy_id: record.policy_id,
  #         policy_name: record.policy&.name,
  #         status_id: record.status&.id,
  #         status_name: record.status&.name&.titleize,
  #         sequence_id: record.order_number,
  #         description: record.title,
  #         narration: record.note,
  #     }.merge(Indexes::Vp::Helpers::Collaborators(record))
  #   end
  #
  # end

end