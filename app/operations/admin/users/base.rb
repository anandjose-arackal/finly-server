class Admin::Users::Base < Admin::Base
  attr_accessor :selected_user

  class Admin::Users::Base::UserPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :created_user, :selected_user, :cards, :policies, :mapping,
                  :managers, :finance_managers, :wallet, :user_panel_subscription,
                  :itz_cash_card_programs, :reviewers, :creditors,
                  :mapping_em, :mapping_vp

    def init
      self.created_user = params[:created_user]
      self.selected_user = params[:selected_user]
      self.wallet = selected_user.wallet
      self.cards = retrieve_card_data
      self.policies = selected_user.policies
      self.user_panel_subscription = selected_user.user_panel_subscription

      self.mapping = []
      self.policies.each do |policy|
        op = Admin::Policy::Mappings::Show.(user, user: selected_user, policy: policy)
        self.mapping << op.map
      end

      self.managers = selected_user.company.users.signed_up.with_roles.only_managers
      self.finance_managers = selected_user.company.users.signed_up.with_roles.only_finance_managers
      self.reviewers = selected_user.company.users.signed_up.with_roles.only_vendor_payment_reviewers
      self.creditors = selected_user.company.users.signed_up.with_roles.only_vendor_payment_creditors
      self.itz_cash_card_programs = ItzCashCardProgram.all
    end

    def retrieve_card_data
      cards = self.selected_user.cards
      data = []
      cards.each do |card|
        result = ItzCash::AccountDetails.(card.user, card: card)
        request = {
            card: card,
            proxy: card.proxy,
            balance: (result.balance rescue 0),
            eligibility: (result.available_card_eligibility rescue 0),
            active: ((result.suspended_status rescue nil) == 'N' ? true : false),
            status: {id: card.card_status.id, name: card.card_status.name}
        }
        unless card.assigned?
          assign_request = card.card_assign_requests.with_card_owner_id(selected_user.id).first
          if assign_request.present?
            request[:assign_request] = {
                id: assign_request.id,
                status: {
                    id: assign_request.status.id,
                    name: assign_request.status.name
                }
            }
          end
        end
        data << request
      end
      data
    end

    def individual_kyc_data
      data = {}
      if selected_user.individual_kyc.present? && selected_user.individual_kyc.kyc_status_id > 1
        kyc_file_1_url = selected_user.individual_kyc.kyc_file_1.present? ? selected_user.individual_kyc.kyc_file_1&.url : selected_user.individual_kyc.id_proof.url
        kyc_file_1_file_type = selected_user.individual_kyc.kyc_file_1.present? ? selected_user.individual_kyc.kyc_file_1&.url : selected_user.individual_kyc.id_proof.url
        data[:id_proof] = {
            url: kyc_file_1_url,
            file_type: kyc_file_1_file_type
        }


        kyc_file_2_url = (selected_user.individual_kyc.kyc_file_2.present? ? selected_user.individual_kyc.kyc_file_2&.url : selected_user.individual_kyc.address_proof.url)
        kyc_file_2_file_type = (selected_user.individual_kyc.kyc_file_2.present? ? selected_user.individual_kyc.kyc_file_2&.content_type : selected_user.individual_kyc.address_proof.content_type)
        data[:address_proof] = {
            url: kyc_file_2_url,
            file_type: kyc_file_2_file_type
        }
      end
      data
    end
  end
end
