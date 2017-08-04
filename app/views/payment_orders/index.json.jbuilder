ar = []
10.times do |ind|
  a = {
      id: ind + 1,
      amount: {
          value: 2000.00,
          currency: "INR",
      },
      payments_count: 10,
      scheduled_date: '18 May 2018',
      processed_date: '19, May, 2018',
      status: {
        id: 1,
        name: 'Complete'
      }
  }
  ar.push(a)
end

json.array! ar