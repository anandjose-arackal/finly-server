require 'dry/monads'
require 'dry/monads/do'
class Admin::Implementations::Master::BBPS::Import < Admin::Implementations::Processor::Import
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:build_params)

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'bbps_subscription.import'
  headers({
              :initiator => "Initiator / Creator of Subscription*",
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
              :policy_name => "Policy*",
              :poc => "POCs Email(Separated by commas)*",
              :destroy => "Destroy"
          })
  attr_accessor :bank_account_params

  def create_record(data)
    subscription = Docs::UtilityBills::Subscriptions::Contracts::Base.new(BbpsBillerSubscription.new)

    params = build_params data

    unless subscription.validate params and subscription.persist
      return result false, subscription.errors.full_messages.join(", ")
    end

    result true, 'Create Successfully'
  end

  def update_record(data)
    bank_account_params, messages = set_params(data)

    unless messages.blank?
      return result false, messages.join(', ')
    end
    user = bank_account_params[:user]
    bank_account = user.bank_accounts.find_by id: data[:id]
    unless bank_account
      return result false, "Bank Account not found"
    end

    unless bank_account.update(bank_account_params.except(:user))
      return result false, bank_account.errors.full_messages
    end
    result true, 'Updated Successfully'
  end

  def destroy_records(data)
    bank_account_params, messages = set_params(data)

    unless messages.blank?
      return result false, messages.join(', ')
    end

    user = bank_account_params[:user]
    bank_account = user.bank_accounts.find_by id: data[:id]
    unless bank_account
      return result false, "Bank Account not found"
    end

    begin
      unless bank_account.destroy
        return result false, bank_account.errors.full_messages
      end
    rescue Exception => e
      return result false, "#{e.message}"
    end

    result true, "Destroyed Successfully"
  end

  def build_params(data)
    params = {}
    params[:company_id] = company&.id
    params[:user_id] = yield find_user(data[:initiator])
    params[:policy_id] = yield find_policy(data[:policy])
    params[:department_id] = yield find_department(data[:department])
    params[:location_id] = yield find_location(data[:location])
    params[:cost_center_id] = yield find_cost_center(data[:cost_center])
    params[:category_id] = yield find_category(data[:category])
    params[:tax_rate_id] = yield find_tax_rate(data[:tax_rate])
    params[:subscription_pocs] = yield find_pocs(data[:poc], required: true)
    params
  end

  def find_user(identifier, required: false)
    find error_key: "User #{identifier}", required: required do
      company.users.find_by(email: identifier)
    end
  end

  def find_policy(identifier, required: false)
    find error_key: 'Policy', required: required do
      company.policies.find_by(name: identifier)&.first
    end
  end

  def find_department(identifier, required: false)
    find error_key: 'Department', required: required do
      company.departments.find_by(name: identifier)&.first
    end
  end

  def find_location(identifier, required: false)
    find error_key: 'Location', required: required do
      company.locations.find_by(name: identifier)&.first
    end
  end

  def find_cost_center(identifier, required: false)
    find error_key: 'Cost_center', required: required do
      company.cost_centers.find_by(name: identifier)&.first
    end
  end

  def find_category(identifier, required: false)
    find error_key: 'Category', required: required do
      company.categories.find_by(name: identifier)&.first
    end
  end

  def find_tax_rate(identifier, required: false)
    find error_key: 'Tax Rate', required: required do
      company.tax_rates.find_by(name: identifier)&.first
    end
  end

  def find_pocs(pocs, required: false)
    ids = pocs.split(",").map { |item| item.strip }
    users = ids.map { |id| find_user(id, required: required) }
    users.map do |user_result|
      return user_result if user_result.success?

      {
          user_id: user_result.success.id
      }
    end
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

