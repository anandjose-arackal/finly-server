class Procurements::Bbps::Subscription::Form < Forms::API

  model BbpsBillerSubscription
  section :header do
    sequence :subscription_id, key: :bbps_biller_subscription
    dropdown :department_id, label: 'Department', required: true, chained: :policy_id,
             enum: {provider: DepartmentProvider}
    dropdown :cost_center_id, label: 'CostCenter', required: true, chained: :policy_id,
             enum: {provider: CostCenterProvider, chained: :policy_id}
    dropdown :location_id, label: 'Location', required: true, chained: :policy_id,
             enum: {provider: LocationProvider}
    dropdown :policy_id, label: 'Policy', required: true,
             enum: {provider: PolicyProvider, filters: {role: UserRole.id_for(:bbps_subscription_initiator)}}
    text :note, attributes: {char_limit: 1000}
  end

  section :general do
    lookup :associated_agreement_id, enum: {provider: AgreementsProvider}
    lookup :point_of_contact
    integer :day_of_billing
    integer :reminder
    integer :payment_term
  end

  section :attachments do
    attachment :agreement, label: 'Agreement', options: {start_date: true, end_date: true, template: "URL TO TEMPLATE"}
    attachment :others, label: "Others", options: {}
  end

end