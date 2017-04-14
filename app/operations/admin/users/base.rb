class Admin::Users::Base < Admin::Base

  attr_accessor :selected_user

  class Admin::Users::Base::UserPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :created_user, :selected_user, :cards, :policies, :mapping,
                  :managers, :finance_managers

    def init
      self.created_user = params[:created_user]
      self.selected_user = params[:selected_user]
      self.cards = selected_user.cards if selected_user
      self.policies = selected_user.policies

      self.mapping = [Policy::Mappings::Show.(user, user: selected_user, policy: nil).map]
      self.policies.each do |policy|
        self.mapping << Policy::Mappings::Show.(user, user: selected_user, policy: policy).map
      end

      self.managers = selected_user.company.users.signed_up.with_roles.only_managers
      self.finance_managers = selected_user.company.users.signed_up.with_roles.only_finance_managers
    end
  end
end
