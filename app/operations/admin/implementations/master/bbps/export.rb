class Admin::Implementations::Master::BBPS::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'bbps.export'

  headers({
              :initiator => "Initiator / Creator of Subscription*",
              :category => "Category (for Reference) [Optional]",
              :biller_id => "Biller ID*",
              :biller_name => "Biller Name (for Reference) [Optional]",
              :associated_mobile_number => "Associated Mobile Number*",
              :custom_param_1 => "Custom Param 1",
              :custom_param_2 => "Custom Param 2",
              :custom_param_3 => "Custom Param 3",
              :custom_param_4 => "Custom Param 4",
              :custom_param_5 => "Custom Param 5",
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

  def initiator(subscription)
    subscription.user&.email
  end

  def category(subscription)
    subscription.category.name
  end

  def biller_id(subscription)
    subscription.biller&.biller_id
  end

  def biller_name(subscription)
    subscription.biller&.biller_name
  end

  def associated_mobile_number(subscription)
    subscription.mobile_number
  end

  def custom_param_1(subscription)
    subscription.customer_param_value_1
  end

  def custom_param_2(subscription)
    subscription.customer_param_value_2
  end

  def custom_param_3(subscription)
    subscription.customer_param_value_3
  end

  def custom_param_4(subscription)
    subscription.customer_param_value_4
  end

  def custom_param_5(subscription)
    subscription.customer_param_value_5
  end

  def location(subscription)
    subscription.location&.location_code
  end

  def department(subscription)
    subscription.department&.department_code
  end

  def cost_center(subscription)
    subscription.cost_center&.cost_center_code
  end

  def policy(subscription)
    subscription.cost_center&.name
  end

  def poc(subscription)
    subscription.pocs.pluck(:email).join(", ")
  end

  def destroy(subscription)

  end


end
