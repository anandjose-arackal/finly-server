class Admin::Implementations::Master::BBPS::ImportTemplate < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'bbps_subscriptions.import_template'
  headers ({
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
    []
  end

  def post_process
  end

end
