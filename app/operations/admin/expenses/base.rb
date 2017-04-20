class Admin::Expenses::Base < Admin::Base


  def expense_params
    params.require(:expense).permit(:note, :category_id, :date, :expense_status_id,
                                    amount_attributes: [:value, :currency_id],
                                    manual_expense_attributes: [:merchant])
  end

  class Admin::Expenses::Base::ExpensePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :expense

    def init
      self.expense = params[:expense]
    end
  end
end