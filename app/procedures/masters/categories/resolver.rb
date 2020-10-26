class Masters::Categories::Resolver < Resolver::API

  entity Category

  def load(params)
    categories = user.company.categories
    if app.to_s == 'em'
      return categories.expense_management_only
    elsif app.to_s == 'vp'
      return categories.vendor_payments_only
    end
    Category.none
  end

end