class SeedDataForStateCodes < ActiveRecord::Migration[5.2]
  def change
    codes = ["35",
             "37",
             "12",
             "18",
             "10",
             "04",
             "22",
             "26",
             "25",
             "07",
             "30",
             "24",
             "06",
             "02",
             "01",
             "20",
             "29",
             "32",
             "31",
             "23",
             "27",
             "14",
             "17",
             "15",
             "13",
             "21",
             "", # because Outside India
             "34",
             "03",
             "08",
             "11",
             "33",
             "36",
             "16",
             "09",
             "05",
             "19"]

    State.all.reorder(name: :asc).each_with_index do |state, index|
      state.update(state_code: codes[index])
    end
  end
end
