class Admin::Implementations::Master::BBPS::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'bbps_subscriptions.export'

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

  def valid_request

  end

  def input
    BbpsBillerSubscription.where(:company_id => company.id)
  end

  def id(subscription)
    subscription.id
  end

  def initiator(subscription)
    subscription.user&.email
  end

  def name(subscription)
    subscription.name
  end

  def category_id(subscription)
    subscription.category&.name
  end

  def bbps_biller_id(subscription)
    subscription.biller&.biller_id
  end

  def biller_name(subscription)
    subscription.biller&.biller_name
  end

  def mobile_number(subscription)
    subscription.mobile_number
  end

  def customer_param_value_1(subscription)
    subscription.customer_param_value_1
  end

  def customer_param_value_2(subscription)
    subscription.customer_param_value_2
  end

  def customer_param_value_3(subscription)
    subscription.customer_param_value_3
  end

  def customer_param_value_4(subscription)
    subscription.customer_param_value_4
  end

  def customer_param_value_5(subscription)
    subscription.customer_param_value_5
  end

  def location(subscription)
    subscription.location&.name #.location_code
  end

  def department(subscription)
    subscription.department&.name #.department_code
  end

  def cost_center(subscription)
    subscription.cost_center&.name #.cost_center_code
  end

  def policy(subscription)
    subscription.policy&.name
  end

  def poc(subscription)
    subscription.pocs.pluck(:email).join(", ")
  end

  def destroy(subscription)

  end


end
