User.delete_all
Gismo.delete_all
Lot.delete_all 


User.create!(name: "Niff", purse: 120.00, gismos: [
  Gismo.new(name: "Spoon", quantity: 4, price: 15.00),
  Gismo.new(name: "Fork", quantity: 15, price: 17.00),
  Gismo.new(name: "Plate", quantity: 3, price: 20.00),
  Gismo.new(name: "Bottle", quantity: 20, price: 5.00),
  Gismo.new(name: "Glass", quantity: 6, price: 12.00),
])
User.create!(name: "Naff", purse: 380.00, gismos: [
  Gismo.new(name: "Elephant", quantity: 8, price: 9.00),
  Gismo.new(name: "Rabbit", quantity: 30, price: 3.00),
  Gismo.new(name: "Wolf", quantity: 4, price: 15.00),
  Gismo.new(name: "Bear", quantity: 3, price: 20.00),
  Gismo.new(name: "Elk", quantity: 12, price: 13.00),
  Gismo.new(name: "Crocodile", quantity: 8, price: 5.00),
  Gismo.new(name: "Hippo", quantity: 14, price: 11.00),
  Gismo.new(name: "Lion", quantity: 10, price: 10.00),
  Gismo.new(name: "Cow", quantity: 22, price: 5.00),
  Gismo.new(name: "Hamster", quantity: 15, price: 1.00)
])
User.create!(name: "Nuff", purse: 200.00, gismos: [
  Gismo.new(name: "Rose", quantity: 10, price: 4.00),
  Gismo.new(name: "Dandelion", quantity: 15, price: 2.00),
  Gismo.new(name: "Gladiolus", quantity: 20, price: 6.00),
  Gismo.new(name: "Lily", quantity: 4, price: 10.00),
  Gismo.new(name: "Orchid", quantity: 7, price: 7.00),
  Gismo.new(name: "Violet", quantity: 12, price: 14.00),
  Gismo.new(name: "Chamomile", quantity: 40, price: 1.00)
])

