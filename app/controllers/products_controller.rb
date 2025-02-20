class ProductsController < ApplicationController
  def show
    @product = { name: "Laptop", price: 1000 }
  end
end
