class AddStateIdToBranchLocationsThatDont < ActiveRecord::Migration[5.2]
  def change
    BranchLocation.all.each do |location|
      if location.gstin.present? && location.state.blank?
        state_code = location.gstin[0..1]
        state = State.find_by state_code: state_code
        location.update(state_id: state&.id)
      end
    end
  end
end
