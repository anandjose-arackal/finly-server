class Admin::Implementations::Master::MoneyRequestCategories::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'money_request_categories.export'

  headers ({
      :id => "ID",
      :name => "Name",
      :active => "Active ( Y / N )",
      :destroy => "Destroy"
  })

  def valid_request

  end

  def input
    company.money_request_item_categories
  end

  def id(money_request_category)
    money_request_category.id
  end

  def active(money_request_category)
    (money_request_category.active ? 'Y' : 'N')
  end

  def name(money_request_category)
    money_request_category.name
  end

  def destroy(money_request_category)
    ''
  end

  def post_process
  end

end
