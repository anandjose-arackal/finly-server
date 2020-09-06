# Synchronizer is responsible for seeding the system masters (defined using DSL) for every company.
# This internally uses the Templates::API.
# This allows differential synchronization where only the newly added fields/masters
# will be synchronized for every company.
#
# Everytime a new master is added, or the entities have changed you should
# run the Synchronizer in a migration by calling Masters::Synchronizer.()
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