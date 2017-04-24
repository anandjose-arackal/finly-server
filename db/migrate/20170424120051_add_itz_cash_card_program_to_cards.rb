class AddItzCashCardProgramToCards < ActiveRecord::Migration
  def change
    if ItzCashCardProgram.count == 0 && Company.count > 0
      ItzCashCardProgram.seed_data
      Card.all.each do |card|
        case card.user.company_id
          when 2 # for Jouska Tech
            card.update(itz_cash_card_program_id: ItzCashCardProgram.id_for(:rbl))
          when 7 # for ItzCash
            card.update(itz_cash_card_program_id: ItzCashCardProgram.id_for(:kotak))
          when 4 # for 5C network
            card.update(itz_cash_card_program_id: ItzCashCardProgram.id_for(:hdfc))
          else
            # do nothing lol
        end
      end
    end
  end
end
