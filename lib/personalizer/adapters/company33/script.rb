class Personalizer::Adapters::Company33::Script

  # c = Company.find(33)
  # unless c.present?
  #   raise "Company not found"
  # end
  # user = c.users.first
  #
  # CustomField::Configuration::Create.(user, field_configuration: {configurable_type: 'Company',
  #                                                                 configurable_id: c.id, company_id: c.id, field_name: 'Type of Expense', field_type_id: FieldType.id_for(:drop_down),
  #                                                                 mandatory: false, global: true, field_parent_type_id: FieldParentType.id_for(:manual_expense),
  #                                                                 drop_down_items_attributes: [
  #                                                                     {name: 'Daily Cash'},
  #                                                                     {name: 'Monthly Expense'},
  #                                                                     {name: 'Employee Expense'}
  #                                                                 ]})
  #
  # CustomField::Configuration::Create.(user, field_configuration: {configurable_type: 'Company',
  #                                                                 configurable_id: c.id, company_id: c.id, field_name: 'Mode of Payment', field_type_id: FieldType.id_for(:drop_down),
  #                                                                 mandatory: false, global: true, field_parent_type_id: FieldParentType.id_for(:manual_expense),
  #                                                                 drop_down_items_attributes: [
  #                                                                     {name: 'Cash'},
  #                                                                     {name: 'Credit'},
  #                                                                     {name: 'Bank Transfer'}
  #                                                                 ]})
  #
  # CustomField::Configuration::Create.(user, field_configuration: {configurable_type: 'Company',
  #                                                                 configurable_id: c.id, company_id: c.id, field_name: 'Unit', field_type_id: FieldType.id_for(:drop_down),
  #                                                                 mandatory: false, global: false, field_parent_type_id: FieldParentType.id_for(:manual_expense),
  #                                                                 drop_down_items_attributes: [
  #                                                                     {name: 'Packets'},
  #                                                                     {name: 'Piece'},
  #                                                                     {name: 'KGs'},
  #                                                                     {name: 'Litres'}
  #                                                                 ]})
  #
  # category_attributes = ["Kirana","Vegetables & Fruits","Electricity ","Hotel rent","Over-time","Advance","Party"].map{|item| {name: item}}
  # CustomField::Configuration::Create.(user, field_configuration: {configurable_type: 'Company',
  #                                                                 configurable_id: c.id, company_id: c.id, field_name: 'Category', field_type_id: FieldType.id_for(:drop_down),
  #                                                                 mandatory: false, global: true, field_parent_type_id: FieldParentType.id_for(:manual_expense),
  #                                                                 drop_down_items_attributes: category_attributes})
  #
  # employee_attributes = ["Gopal.C. Poojari","Damodar P.Prabhu","Suresh N. Sawanta","Basalingappa.M","Arun.E.Naik",
  #                        "Gajanan (CL) S","Mallikarjun .B","Fakirappa","Anatha.R.Gouda","Eashwar.M.Naik",
  #                        "Manjunathr R)","Sharanappa","Amarappa","Basavaraj (cook)","Ravikiran","Uma Prabhu",
  #                        "Channamma Patil","M.Vasudev Rao","Gajanan Balagi","Harish Shanbhag","R.G. Shenoy","Ullas A. Kamat",
  #                        "Sunil.R.Shetty","Girish","Mallesh","santosh","Muthesh","Reshma","Yallappa","Rohan","Shivraj","Yellappa","SANJEEVA"].map{|item| {name: item}}
  # CustomField::Configuration::Create.(user, field_configuration: {configurable_type: 'Company',
  #                                                                 configurable_id: c.id, company_id: c.id, field_name: 'Employees', field_type_id: FieldType.id_for(:drop_down),
  #                                                                 mandatory: false, global: true, field_parent_type_id: FieldParentType.id_for(:manual_expense),
  #                                                                 drop_down_items_attributes: employee_attributes})
  #
  # kirana_attributes = ["Ruchi gold oil","Sunflower oil","Sugar","Rice meals","Sona Masoori  rice",
  #                      "Boiled rice","Basmati rice","Avalakki","Urad dal","Moong dal","Idli rava","Bombay rava","Maida",
  #                      "Aata","Besan","Chiroti rava","Dhaniya","Jeera","Methi","Mustard","Chana dal","Drakash kismis",
  #                      "4 piece kaju","Full kaju","Lavang","Black pepper kal menu","Dalchini","Nadini ghee","Masoori Kalu",
  #                      "Madki kalu","Red chana","Kabuli chana","Moong","White peas vatani","Alsandi","Tasting powder",
  #                      "Edible soda","Vin powder","Sabina","Putani aata","Rice ata","Khobari dry","Napkins","Badisoap",
  #                      "Sugar powder","Tandoori rava","Orange red lemon yellow colour","Food Colour Orange","Food Colour Lemon Yellow",
  #                      "Bournivita","Badam Powder","MTR samabar powder","Black salt","Table salt","Alsande","Jaggery","Jowar",
  #                      "Tamarind","Shenga","Putani","Gurallu","Corn flour","Bee.bee","Magaj","Kaskas","Hing",
  #                      "Tomato sauce","Chilly Sauce","Coconut powder","Noodles","Pav bhaji masala","Aam choor powder","Kasuri methi",
  #                      "Dhaniya powder","Vinegar"].map{|item| {name: item}}
  # CustomField::Configuration::Create.(user, field_configuration: {configurable_type: 'Company',
  #                                                                 configurable_id: c.id, company_id: c.id, field_name: 'Kirana List', field_type_id: FieldType.id_for(:drop_down),
  #                                                                 mandatory: false, global: false, field_parent_type_id: FieldParentType.id_for(:manual_expense),
  #                                                                 drop_down_items_attributes: kirana_attributes})
  #
  # vegatable_attributes = ["Tomato","Green chilli","Cauliflower","Cucumber","Karbev","Kotambari",
  #                         "Pudina","Beans","Carrot","Lemon","Suvarna Gadde","Badnekayi","Hirekayi","Chawlikayi",
  #                         "Soutekayi","Kemp kumbalikayi","Bili kumbalkayi","Palak","Moolanji","Raj Giri",
  #                         "Sambar sautekayi","Capsicum","Onion","Potato","Coconut","pineapple","watermelon",
  #                         "apple","chikku","musumbi","orange"].map{|item| {name: item}}
  # CustomField::Configuration::Create.(user, field_configuration: {configurable_type: 'Company',
  #                                                                 configurable_id: c.id, company_id: c.id, field_name: 'Vegatable and Fruits', field_type_id: FieldType.id_for(:drop_down),
  #                                                                 mandatory: false, global: false, field_parent_type_id: FieldParentType.id_for(:manual_expense),
  #                                                                 drop_down_items_attributes: vegatable_attributes})
  #
  # CustomField::Configuration::Create.(user, field_configuration: {configurable_type: 'Company',
  #                                                                 configurable_id: c.id, company_id: c.id, field_name: 'Unit Price', field_type_id: FieldType.id_for(:text),
  #                                                                 mandatory: false, global: false, field_parent_type_id: FieldParentType.id_for(:manual_expense)})
  #
  # CustomField::Configuration::Create.(user, field_configuration: {configurable_type: 'Company',
  #                                                                 configurable_id: c.id, company_id: c.id, field_name: 'Quantity', field_type_id: FieldType.id_for(:text),
  #                                                                 mandatory: false, global: false, field_parent_type_id: FieldParentType.id_for(:manual_expense)})


end