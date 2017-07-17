class Admin::Users::Base < Admin::Base

  attr_accessor :selected_user

  class Admin::Users::Base::UserPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :created_user, :selected_user, :cards, :policies, :mapping,
                  :managers, :finance_managers, :wallet, :itz_cash_card_programs

    def init
      self.created_user = params[:created_user]
      self.selected_user = params[:selected_user]
      self.wallet = selected_user.wallet
      self.cards = retrieve_card_data
      self.policies = selected_user.policies

      self.mapping = []
      self.policies.each do |policy|
        self.mapping << Policy::Mappings::Show.(user, user: selected_user, policy: policy).map
      end

      self.managers = selected_user.company.users.signed_up.with_roles.only_managers
      self.finance_managers = selected_user.company.users.signed_up.with_roles.only_finance_managers
      self.itz_cash_card_programs = ItzCashCardProgram.all
    end

    def retrieve_card_data
      cards = self.selected_user.cards
      data = []
      cards.each do |card|
        result = ItzCash::AccountDetails.(card.user, card: card)
        data << {
            card: card,
            proxy: card.proxy,
            balance: (result.balance rescue 0),
            eligibility: (result.available_card_eligibility rescue 0),
            active: ((result.suspended_status rescue nil) == 'N' ? true : false)
        }
      end
      data
    end
  end
end
