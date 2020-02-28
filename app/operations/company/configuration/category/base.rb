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

    def mobile_optimized_categories
      cat = []
      self.categories.roots.active.each do |category|
        if category.children.present?
          category.children.active.each do |c|
            cat << {id: c.id, name: "#{category.name } - #{c.name}", active: c.active, gst_applicable: c.gst_applicable, tds_applicable: c.tds_applicable}
          end
        else
          cat << {id: category.id, name: category.name, active: category.active, gst_applicable: category.gst_applicable, tds_applicable: category.tds_applicable}
        end
      end
      cat
    end

  end

end