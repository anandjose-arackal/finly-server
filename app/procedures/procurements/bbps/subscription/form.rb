class Procurements::Bbps::Subscription::Form < Forms::API

  # model BbpsBillerSubscription
  # section :header do
  #   sequence :subscription_id, key: :bbps_biller_subscription
  #   dropdown :department_id, label: 'Department', required: true, chained: :policy_id,
  #            enum: {provider: DepartmentProvider}
  #   dropdown :cost_center_id, label: 'CostCenter', required: true, chained: :policy_id,
  #            enum: {provider: CostCenterProvider}
  #   dropdown :location_id, label: 'Location', required: true, chained: :policy_id,
  #            enum: {provider: LocationProvider}
  #   dropdown :policy_id, label: 'Policy', required: true,
  #            enum: {provider: PolicyProvider, filters: {role: UserRole.id_for(:bbps_subscription_initiator)}}
  #   date :start_date
  #   text :note, attributes: {char_limit: 1000}
  # end
  #
  # section :general do
  #   lookup :associated_agreement_id, label: "Associated Agreement", required: false,
  #          enum: {provider: AgreementsProvider}
  #   lookup :point_of_contact, label: "Point of contact", required: true,
  #          enum: {provider: UserProvider}
  #   integer :billing_day_of_the_month
  #   integer :reminder_days_before_due
  #   integer :payment_term
  # end
  #
  # section :attachments do
  #   attachment :agreement, label: 'Agreement', options: {start_date: true, end_date: true, template: "URL TO TEMPLATE"}
  #   attachment :others, label: "Others", options: {}
  # end

end