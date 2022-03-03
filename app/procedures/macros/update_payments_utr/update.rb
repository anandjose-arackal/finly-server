class Macros::UpdatePaymentsUtr::Update < Transactions::API

  schema do
    params do
      required(:payment_id).filled(:string)
      required(:utr).filled(:string)
      required(:processed_date).filled(:date)
    end
  end

  step :pre_validate
  step :init
  step :update_utr_date_payment
  
  def pre_validate(context, params:, current_user:, record_class:, **)
    if current_user.blank? || params.blank?
      context[:result_data] = "user must not blank"
      return true
    end
    true
  end

  def init(context, params:,current_user:, record_class:, **)
    context[:record] = record_class.find_by(id: params[:payment_id])
    true
  end

  def update_utr_date_payment(context, params:, current_user:, record:, **)
    if record.nil?
      context[:result_data] = "Failure_Check_Payment_Id"
      return true
    elsif record.utr.present?
      context[:result_data] = "Payment_UTR_Already_Exist"
      return true
    end
    if record.completed?
      record.utr = params[:utr]
      record.processed_at = params[:processed_date]
      if record.save
        context[:result_data] = "Payment_UTR_Successfully_Updated"
        return true
      else
        context[:result_data] = "Payment_Not_Updated_Due_To (#{record.errors.full_messages})"
        return true
      end
    else
      context[:result_data] = "Payment_Not_Updated_Due_To_Payment_Status (#{record.payment_status.name})"
      return true
    end
    true
  end

end