class AddPaidByCompanyWallets < ActiveRecord::Migration
  def change
    pocket_type_id = UserPocketType.where(name: 'paid_by_company')&.first&.id
    Company.all.each do |company|
      template = company.company_pocket_templates.create name: 'Paid By Company', user_pocket_type_id: pocket_type_id
      unless template.id.present?
        raise 'Template creation exception'
      end
    end
    User.all.each do |user|
      paid_by_company_template_id = user.company.company_pocket_templates.with_user_pocket_type_id(pocket_type_id)&.first.id
      unless paid_by_company_template_id
        raise 'reimbursement_template_id exception'
      end
      pocket = user.user_pockets.create name: 'Paid By Company', balance: Amount.new(value: 0, currency_id: 1), user_pocket_type_id: pocket_type_id, base_currency_id: 1, company_pocket_template_id: paid_by_company_template_id
      unless pocket
        raise 'pocket exception'
      end
      user.expenses.where(reimbursable: false, from_cash_on_hand: false).all.update_all(spent_from_id: pocket.id)
    end
  end
end
