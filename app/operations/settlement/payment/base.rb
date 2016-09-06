class Settlement::Payment::Base < Settlement::Base

  class Settlement::Payment::Base::Presenter < Settlement::Base::BasePresenter
    attr_accessor :payment

    def initialize(user, params)
      super(user, params)
      self.payment = params[:payment]
    end
  end

  def pre_validate
    super()
    if params[:payment][:currency_id].blank? # temporary, will be changed once currencies are implemented
      params[:payment][:currency_id] = 1
    end
  end

  def payment_params
    params.require(:payment).permit(:total, :date, :note, :currency_id)
  end
end