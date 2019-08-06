puts 'Cleaning database...'
Product.destroy_all
Category.destroy_all

puts 'Creating categories...'
geek = Category.create!(name: 'geek')
kids = Category.create!(name: 'kids')

puts 'Creating teddies...'
Product.create!(sku: 'original-teddy-bear', name: 'Product bear', category: kids, photo_url: 'http://onehdwallpaper.com/wp-content/uploads/2015/07/Product-Bears-HD-Images.jpg', price: 100)
Product.create!(sku: 'jean-mimi', name: 'Jean-Michel - Le Wagon', category: geek, photo_url: 'https://pbs.twimg.com/media/B_AUcKeU4AE6ZcG.jpg:large', price: 200)
Product.create!(sku: 'octocat',   name: 'Octocat -  GitHub',      category: geek, photo_url: 'https://cdn-ak.f.st-hatena.com/images/fotolife/s/suzumidokoro/20160413/20160413220730.jpg', price: 150)
puts 'Finished!'
