class Admin::Payments::StatusCheck < Admin::Payments::Base

  attr_accessor :payment, :company, :reference_resource_type

  def pre_validate
    if params.blank? || params[:payment_id].blank? || user.blank?
      add_message :error, "Invalid parameters, please try again"
      return
    end
  end

  def init
    payment_id = params[:id] || params[:payment_id]
    company_id = params[:company_id]
    self.payment = Payment.find_by(id: payment_id, company_id: company_id )
    if payment.blank?
        add_message :error, "Cannot find the Payment"
      return
    end
    self.reference_resource_type = payment.reference_resource_type
  end

  def validate
    unless ['IciciBankTransaction', 'KotakBankTransaction', 'YesBankTransaction'].include?(reference_resource_type)
      add_message :error, "Please specify correct payment type."
      return
    end
  end

  def process      
    reference_resources = payment.reference_resources.first
    if reference_resources.present?
      reference_resources.update(transfer_status_id: BankTransferStatus.id_for(:pending_for_processing))

      case reference_resource_type
      when 'IciciBankTransaction'
        IciciStatusChecker.perform()
      when 'KotakBankTransaction'
        KotakBankTransferStatusChecker.perform()
      when 'YesBankTransaction'
        YesBankStatusChecker.perform()
      else
        nil
        #do nothing..
      end
      sleep 3
    else
      add_message :info, "Could not fetch status from bank."
    end
  end

  def success
    params[:status] = payment.payment_status.name
    params[:payment] = payment
    Admin::Payments::Base::PaymentPresenter.new(user, params, messages)
  end 
end