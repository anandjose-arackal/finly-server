class Admin::Companies::Base < Admin::Base

  def pre_validate
    super()
  end

  def company_params
    params.require(:company).permit(:name, itz_cash_property_attributes: [:d_code], configuration_attributes: [:logo],
                                    company_kyc_attributes: [:company_type_id, :customer_type_id],
                                    feature_subscription_attributes: [
                                      :ocr_enabled,
                                      :expense_management_enabled,
                                      :gift_card_enabled,
                                      :gift_voucher_enabled,
                                      :meal_card_enabled,
                                      :fuel_card_enabled,
                                      :medical_card_enabled,
                                      :expense_card_enabled,
                                      :reimbursement_card_enabled,
                                      :hard_copy_receipt
                                    ])
  end

  def success
    Admin::Companies::Base::CompanyPresenter.new(user, {company: company}, messages)
  end

  class Admin::Companies::Base::CompanyPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :company

    def init
      self.company = params[:company]
    end

    def company_balance
      op = Company::VirtualAccount::Balance.(user, {company: company})
      op&.success? ? op.balance : nil
    end
  end

end