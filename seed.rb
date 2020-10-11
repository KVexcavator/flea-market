Player.delete_all 
Gismo.delete_all
Lot.delete_all 


Player.create!(nik: "Niff", purse: 120.00, gismos: [
  Gismo.new(title: "Spoon", quantity: 4, price: 15.00),
  Gismo.new(title: "Fork", quantity: 15, price: 17.00),
  Gismo.new(title: "Plate", quantity: 3, price: 20.00),
  Gismo.new(title: "Bottle", quantity: 20, price: 5.00),
  Gismo.new(title: "Glass", quantity: 6, price: 12.00),
])
Player.create!(nik: "Naff", purse: 380.00, gismos: [
  Gismo.new(title: "Elephant", quantity: 8, price: 9.00),
  Gismo.new(title: "Rabbit", quantity: 30, price: 3.00),
  Gismo.new(title: "Wolf", quantity: 4, price: 15.00),
  Gismo.new(title: "Bear", quantity: 3, price: 20.00),
  Gismo.new(title: "Elk", quantity: 12, price: 13.00),
  Gismo.new(title: "Crocodile", quantity: 8, price: 5.00),
  Gismo.new(title: "Hippo", quantity: 14, price: 11.00),
  Gismo.new(title: "Lion", quantity: 10, price: 10.00),
  Gismo.new(title: "Cow", quantity: 22, price: 5.00),
  Gismo.new(title: "Hamster", quantity: 15, price: 1.00)
])
Player.create!(nik: "Nuff", purse: 200.00, gismos: [
  Gismo.new(title: "Rose", quantity: 10, price: 4.00),
  Gismo.new(title: "Dandelion", quantity: 15, price: 2.00),
  Gismo.new(title: "Gladiolus", quantity: 20, price: 6.00),
  Gismo.new(title: "Lily", quantity: 4, price: 10.00),
  Gismo.new(title: "Orchid", quantity: 7, price: 7.00),
  Gismo.new(title: "Violet", quantity: 12, price: 14.00),
  Gismo.new(title: "Chamomile", quantity: 40, price: 1.00)
])

Lot.create!(seller: "Naff", description: "Gismos: Lily quantity: 11", total: 70.00)
Lot.create!(seller: "Naff", description: "Gismos: Bottle quantity: 7", total: 20.00)
Lot.create!(seller: "Niff", description: "Gismos: Orchid quantity: 3", total: 15.00)
Lot.create!(seller: "Niff", description: "Gismos: Wolf quantity: 12", total: 400.00)
Lot.create!(seller: "Niff", description: "Gismos: Plate quantity: 4", total: 55.00)
Lot.create!(seller: "Nuff", description: "Gismos: Elephant quantity: 2", total: 35.00)
