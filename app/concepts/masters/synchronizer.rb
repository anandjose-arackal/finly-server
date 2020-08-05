class Masters::Synchronizer

  def self.call
    Masters::Router.masters.each { |master| sync(master) }
  end

  def self.sync(master)
    schema = master.schema
    template = Masters::Template.new(schema)
    Company.limit(2).last(1).each do |company|
      user = company.users.first
      # Synchronize master
      template.sync(company_id: company.id, user: user)
    end
  end

end