class Admin::Implementations::Master::MoneyRequestCategories::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'money_request_categories.import_template'
  headers ({
      :id => "ID",
      :name => "Name",
      :active => "Active ( Y / N )",
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
