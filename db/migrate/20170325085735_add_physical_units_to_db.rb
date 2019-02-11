class AddPhysicalUnitsToDb < ActiveRecord::Migration[4.2]
  def change
    if PhysicalUnit.count == 0
      PhysicalUnit::VALUES.each do |k, v|
        PhysicalUnit.create(id: k, name: v[:name], symbol: v[:symbol])
      end
    end
  end
end
