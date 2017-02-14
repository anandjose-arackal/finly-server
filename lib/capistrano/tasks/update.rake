namespace :update do
  
  desc "Fixing user card restriction association"
  task :association_fix => :environment do
    User.all.each do |user|
      res = CardRestriction.find_by(card_id: user.id)
      if user.cards.present?
        card = user.cards.first
        res.update(card_id: card.id)
      else
        res.destroy
      end
    end
  end

end