class Masters::Policies::FilterConfig < Filters::API

  # permissions *index_builder.permissions if index_builder.permissions.present?
  system_subscription :em, :vp # *index_builder.system_subscription if index_builder.system_subscription.present?
  # feature_subscription index_builder.feature_subscription
  # user_subscription index_builder.user_subscription

  attribute :name, type: :text, simple: true
  attribute :created_at, type: :datetime
  attribute :updated_at, type: :datetime

end