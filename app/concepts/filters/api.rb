class Filters::API < Transactions::API
  include DynamicAttributes
  include Attribute::Builder

  step :build_attributes
  step :build_config

  class_attr :feature_subscription
  class_attr :user_subscription

  def self.permissions(*permissions)
    @permissions = permissions if permissions.present?

    @permissions
  end

  def self.system_subscription(*system_subscription)
    @system_subscription = system_subscription if system_subscription.present?

    @system_subscription
  end

  # Load permissions / subscription / systems from index builder
  def self.index_builder(index_builder)
    permissions *index_builder.permissions if index_builder.permissions.present?
    system_subscription *index_builder.system_subscription if index_builder.system_subscription.present?
    feature_subscription index_builder.feature_subscription
    user_subscription index_builder.user_subscription
  end

  def build_attributes(context, current_user:, **)
    context[:attributes] = attributes(context)
  end

  def build_config(context, current_user:, **)
    unless context[:only_attributes]
      context[:filters] = build(context, current_user)
    end
  end

  # def build(context, current_user)
  #   self.class.build(context, current_user)
  # end

  def attributes(context)
    self.class.attributes
  end

  def custom_fields
    self.class.custom_fields
  end
end