class BooksController < ApplicationController
  def index
    @books = Book.all
    # head :no_content
    # redirect_to root_path
  end
end
