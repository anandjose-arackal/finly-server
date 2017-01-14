# == Schema Information
#
# Table name: states
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  code       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#



class State < ActiveRecord::Base

  VALUES = [{:code => 'S00', :name => 'Outside India'}, {:code => 'S01', :name => 'Maharashtra'}, {:code => 'S02', :name => 'Gujarat'}, {:code => 'S03', :name => 'Andhra Pradesh'},
            {:code => 'S04', :name => 'Arunachal Pradesh'}, {:code => 'S05', :name => 'Assam'}, {:code => 'S06', :name => 'Bihar'}, {:code => 'S07', :name => 'Chattisgarh'},
            {:code => 'S08', :name => 'Andaman and Nicobar Islands'}, {:code => 'S09', :name => 'Chandigarh'}, {:code => 'S10', :name => 'Dadra and Nagar Haveli'},
            {:code => 'S11', :name => 'Daman and Diu'}, {:code => 'S12', :name => 'Delhi'}, {:code => 'S13', :name => 'Goa'}, {:code => 'S14', :name => 'Haryana'},
            {:code => 'S15', :name => 'Himachal Pradesh'}, {:code => 'S16', :name => 'Jammu and Kashmir'}, {:code => 'S17', :name => 'Jharkhand'}, {:code => 'S18', :name => 'Karnataka'},
            {:code => 'S19', :name => 'Kerala'}, {:code => 'S20', :name => 'Lakshadweep'}, {:code => 'S21', :name => 'Madhya Pradesh'}, {:code => 'S22', :name => 'Manipur'},
            {:code => 'S23', :name => 'Meghalaya'}, {:code => 'S24', :name => 'Mizoram'}, {:code => 'S25', :name => 'Nagaland'}, {:code => 'S26', :name => 'Orissa'},
            {:code => 'S27', :name => 'Pondicherry'}, {:code => 'S28', :name => 'Punjab'}, {:code => 'S29', :name => 'Rajasthan'}, {:code => 'S30', :name => 'Sikkim'},
            {:code => 'S31', :name => 'Tamil Nadu'}, {:code => 'S32', :name => 'Tripura'}, {:code => 'S33', :name => 'Uttar Pradesh'}, {:code => 'S34', :name => 'Uttaranchal'},
            {:code => 'S35', :name => 'West Bengal'}, {:code => 'S36', :name => 'Telangana'}]

  scope :with_id, -> (id) {where(id: id)}

  def self.name_for(state_id)
    return nil if state_id.blank?
    VALUES.each do |map|
      if map[:code] == state_id
        return map[:name]
      end
    end
    nil
  end

end
