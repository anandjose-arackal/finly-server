class UserPockets::AssignablePockets < UserPockets::Base

  attr_accessor :pocket_templates, :existing_pockets, :selected_user

  def init
    selected_user_id = params[:id] || params[:selected_user_id]
    self.selected_user = current_company.users.find_by(id: selected_user_id)
    self.selected_user = user if self.selected_user.blank?
    self.existing_pockets = self.selected_user.user_pockets
  end

  def process
    pocket_template_ids = user.company.company_pocket_templates.pluck(:id)
    applicable_pocket_templates = pocket_template_ids - self.existing_pockets.pluck(:company_pocket_template_id)
    self.pocket_templates = CompanyPocketTemplate.with_id(applicable_pocket_templates)
  end

  def success
    params[:pocket_templates] = self.pocket_templates
    UserPockets::AssignablePockets::PocketsPresenter.new(user, params, messages)
  end

  class UserPockets::AssignablePockets::PocketsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :pocket_templates

    def init
      self.pocket_templates = params[:pocket_templates]
    end
  end
end