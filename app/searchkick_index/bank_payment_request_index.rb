class BankPaymentRequestIndex < Searchkick::Api::DSL

  scope do
    includes(:policy, :status, :created_by, {payment_order: :payment_order_status})
  end

  record_type 'payment_tickets'

  field :policy_id, displayable: false, searchable: false
  field :policy_name, value: '{{record.policy.name}}'
  field :status_name, value: '{{record.status_name}}'
  field :sequence_id, value: '{{record.id}}'
  field :narration, value: '{{record.description}}'
  field :description, value: '{{record.name}}'
  field :created_by_name, value: '{{record.created_by.name}}'
  field :created_by_email, value: '{{record.created_by.name}}'

  # index Indexes::Vp do
  #   include_associations :policy, :status, Indexes::Vp::Helpers::INCLUDE_COLLABORATORS, :created_by, {payment_order: :payment_order_status}
  #
  #   document_type :payment_tickets
  #   permissions Docs::PaymentTickets::Index.permissions
  #   category :transactions
  #   route 'orders/{{record_id}}/params={}'
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
  #         status_name: record.status_name&.titleize,
  #         sequence_id: record.id,
  #         narration: record.description,
  #         description: record.name,
  #         created_by_name: record.created_by&.name,
  #         created_by_email: record.created_by&.email,
  #     }.merge(Indexes::Vp::Helpers::Collaborators(record))
  #   end
  #
  # end

end