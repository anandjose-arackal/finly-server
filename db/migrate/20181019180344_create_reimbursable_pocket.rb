class CreateReimbursablePocket < ActiveRecord::Migration
  def change
    UserPocketType.seed_data
    pocket_type_id = UserPocketType.where(name: 'reimbursement')&.first&.id
    Company.all.each do |company|
      template = company.company_pocket_templates.create name: 'Reimbursement', user_pocket_type_id: pocket_type_id
      unless template.id.present?
        debugger
        raise 'Template creation exception'
      end
    end
    User.all.each do |user|
      reimbursement_template_id = user.company.company_pocket_templates.with_user_pocket_type_id(pocket_type_id)&.first.id
      unless reimbursement_template_id
        debugger
        raise 'reimbursement_template_id exception'
      end
      pocket = user.user_pockets.create name: 'Reimbursement', balance: Amount.new(value: 0, currency_id: 1), user_pocket_type_id: pocket_type_id, base_currency_id: 1, company_pocket_template_id: reimbursement_template_id
      unless pocket
        debugger
        raise 'pocket exception'
      end
      user.expenses.reimbursable.all.update_all(spent_from_id: pocket.id)
    end
  end
end
