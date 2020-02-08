require 'dry/monads'
require 'dry/monads/do'
class Admin::Implementations::Master::BBPS::Import < Admin::Implementations::Processor::Import
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:build_params)

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'bbps_subscriptions.import'
  headers({
              :id => "ID",
              :initiator => "Initiator / Creator of Subscription*",
              :name => "Name*",
              :category_id => "Category (for Reference) [Optional]",
              :bbps_biller_id => "Biller ID*",
              :biller_name => "Biller Name (for Reference) [Optional]",
              :mobile_number => "Associated Mobile Number*",
              :customer_param_value_1 => "Custom Param 1",
              :customer_param_value_2 => "Custom Param 2",
              :customer_param_value_3 => "Custom Param 3",
              :customer_param_value_4 => "Custom Param 4",
              :customer_param_value_5 => "Custom Param 5",
              :location => "Location*",
              :department => "Department",
              :cost_center => "Cost Center",
              :policy => "Policy*",
              :poc => "POCs Email(Separated by commas)*",
              :destroy => "Destroy"
          })
  attr_accessor :bank_account_params

  def create_record(data)
    subscription_model = BbpsBillerSubscription.new
    subscription_model.status_id = BbpsBillerSubscriptionStatus.id_for(:auto_approved)
    create_or_update(subscription_model, data, success_message: "Created Successfully")
  end

  def update_record(data)
    create_or_update(find_subscription(data[:id]), data, success_message: "Updated Successfully")
  end

  def destroy_records(data)
    bbps_subscription = find_subscription(data[:id])

    unless bbps_subscription.present?
      return result false, "Subscription not found"
    end

    unless bbps_subscription.destroy
      return result false, bbps_subscription.errors.full_messages
    end

    result true, "Destroyed Successfully!"
  end

  def find_subscription(id)
    company.bbps_subscriptions.find_by(id: id)
  end

  def create_or_update(subscription_model, data, success_message:)
    unless subscription_model.present?
      return result false, "Subscription not found"
    end

    subscription = Docs::UtilityBills::Subscriptions::Contracts::Base.new(subscription_model)
    format_data = build_params data

    unless format_data.success?
      return result false, format_data.failure
    end

    input = data.merge(format_data.success)

    unless subscription.validate(input) and subscription.save
      return result false, subscription.errors.full_messages.join(", ")
    end

    unless subscription.model.persisted?
      return result false, subscription.model.errors.full_messages.join(", ")
    end

    result true, success_message
  end

  def build_params(data)
    params = {}
    params[:company_id] = company&.id
    params[:current_user] = yield find_user(data[:initiator])
    params[:user_id] = params[:current_user]&.id
    params[:policy_id] = (yield find_policy(data[:policy]))&.id
    params[:department_id] = (yield find_department(data[:department]))&.id
    params[:location_id] = (yield find_location(data[:location]))&.id
    params[:cost_center_id] = (yield find_cost_center(data[:cost_center]))&.id
    params[:category_id] = (yield find_category(data[:category]))&.id
    params[:tax_rate_id] = (yield find_tax_rate(data[:tax_rate]))&.id
    biller = yield find_bbps_biller(data[:bbps_biller_id], required: true)
    params[:bbps_biller_id] = biller.id
    params[:customer_param_key_1] = biller.biller_customer_params[0]&.dig('param_name')
    params[:customer_param_key_2] = biller.biller_customer_params[1]&.dig('param_name')
    params[:customer_param_key_3] = biller.biller_customer_params[2]&.dig('param_name')
    params[:customer_param_key_4] = biller.biller_customer_params[3]&.dig('param_name')
    params[:customer_param_key_5] = biller.biller_customer_params[4]&.dig('param_name')
    params[:subscription_pocs] = yield find_pocs(data[:poc], required: true)

    Success(params)
  end

  def find_user(identifier, required: false)
    find error_key: "User #{identifier}", required: required do
      company.users.find_by(email: identifier)
    end
  end

  def find_policy(identifier, required: false)
    find error_key: 'Policy', required: required do
      company.policies.find_by(name: identifier)
    end
  end

  def find_department(identifier, required: false)
    find error_key: 'Department', required: required do
      company.departments.find_by(name: identifier)
    end
  end

  def find_location(identifier, required: false)
    find error_key: 'Location', required: required do
      company.locations.find_by(name: identifier)
    end
  end

  def find_cost_center(identifier, required: false)
    find error_key: 'Cost_center', required: required do
      company.cost_centers.find_by(name: identifier)
    end
  end

  def find_category(identifier, required: false)
    find error_key: 'Category', required: required do
      company.categories.find_by(name: identifier)
    end
  end

  def find_tax_rate(identifier, required: false)
    find error_key: 'Tax Rate', required: required do
      company.tax_rates.find_by(name: identifier)
    end
  end

  def find_bbps_biller(biller_id, required: false)
    find error_key: 'Biller', required: required do
      BbpsBiller.find_by(biller_id: biller_id)
    end
  end

  def find_pocs(pocs, required: false)
    ids = pocs.split(",").map { |item| item.strip }
    users = ids.map { |id| find_user(id, required: required) }
    pocs = users.map do |user_result|
      return user_result unless user_result.success?

      {
          user_id: user_result.success&.id
      }
    end
    Success(pocs)
  end

  def find(required: false, error_key: nil, klass: nil, failure_message: nil, &block)
    value = block.call
    if value or not required
      return Success(value)
    end

    failure_message ||= "#{klass} not found" if klass
    failure_message ||= "#{error_key} not found" if error_key
    failure_message ||= "Error: Field is found"
    Failure(failure_message)
  end

end

