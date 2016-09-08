class Company::Configuration::Category::Base < BaseOperation
  attr_accessor :categories

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if self.user.blank?
      errors << 'User not found'
    end
  end

  def init
    self.categories = user.company.categories
  end

  def success
    Company::Configuration::Category::Base::Presenter.new(user, {categories: categories})
  end

  class Company::Configuration::Category::Base::Presenter < BaseOperation::BasePresenter
    attr_accessor :categories

    def initialize(user, params)
      super(user, params)
      self.categories = params[:categories]
    end

  end

end