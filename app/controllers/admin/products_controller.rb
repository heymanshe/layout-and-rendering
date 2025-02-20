class Admin::ProductsController < ApplicationController
  def index
    # This will render `app/views/products/show.html.erb`
    render template: "products/show"
  end
end
