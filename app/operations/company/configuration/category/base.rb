class Company::Configuration::Category::Base < BaseOperation
  attr_accessor :categories

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if self.user.blank?
      messages[:error] << 'User not found'
    end
  end

  def init
    self.categories = user.company.categories
    self.categories = self.categories.active if self.categories.present?
  end

  def success
    Company::Configuration::Category::Base::Presenter.new(user, {categories: categories}, messages)
  end

  class Company::Configuration::Category::Base::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :categories

    def init
      self.categories = params[:categories]
    end

  end

end