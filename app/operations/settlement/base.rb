class Settlement::Base < BaseOperation

  attr_accessor :to_user

  class Settlement::Base::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, 'No user or params passed'
      return false
    end
    # todo - temporary, will be changed once currencies is implemented. Error will be thrown if currency is not provided
    if params[:currency_id].blank?
      params[:currency_id] = 1
    end
  end

  def validate_date(date)
    if date.blank?
      add_message :error, 'Date cannot be blank'
      return false
    end
    unless DateUtils.validate_date_format?(date)
      add_message :error, 'Invalid date format'
      return false
    end
    unless date.is_a?(Date)
      date = Date.parse(date)
    end
    if date.present? and date > DateUtils.local_date
      add_message :error, 'Date cannot be later than the current date'
      return false
    end
    true
  end

  # def retrieve
  #   if success?
  #     return true
  #   else
  #     return false
  #   end
  # end

  def success
    true
  end


end