class ExpenseTypes::PerDiem::Base < ExpenseTypes::Base

  def per_diem_params
    params.require(:per_diem).permit(:name, rate_attributes: [:value, :currency_id])
  end

  class ExpenseTypes::PerDiem::Base::PerDiemPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :per_diem

    def init
      self.per_diem = params[:per_diem]
    end

  end

end