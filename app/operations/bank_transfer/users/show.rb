# this operation shows all the details about this user including the bank transfers done by him / her
# from Finly Vendor Credits or from the company credits

class BankTransfer::Users::Show < BankTransfer::Users::Base

  attr_accessor :selected_user, :role_id

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.role_id = params[:role_id]
    if role_id.blank? && params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
  end

  def validate
    unless role_id.present?
      add_message :error, "User role not defined"
    end
  end

  def process
    case role_id
      when UserRole.id_for(:admin)
        team = BankTransfer::Users::Index.(user, params).users rescue []
        id = params[:id] || params[:user_id]
        self.selected_user = team.find_by(id: id)
      else
        self.selected_user = user
    end
  end

  def success
    params[:selected_user] = selected_user
    BankTransfer::Users::Show::UserPresenter.new(user, params, messages)
  end

  class BankTransfer::Users::Show::UserPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :selected_user, :user_panel_subscription

    def init
      self.selected_user = params[:selected_user]
      self.user_panel_subscription = selected_user.user_panel_subscription
    end
  end

end