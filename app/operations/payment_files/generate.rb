class PaymentFiles::Generate < BaseOperation

  def authorized_user_types
    [:company_admin, :auditor, :finance_manager]
  end

  def pre_validate
    if current_company.blank?
      add_message :error, 'Company not found'
      return
    end
  end

  def init
    unless current_company

    end
  end

  def validate

  end

  def process

  end

end