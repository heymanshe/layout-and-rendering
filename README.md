 # 1. Overview

- This guide explains the interaction between the Controller and View in the Model-View-Controller (MVC) architecture of Rails.

## Key Points

- **Controller's Role** Manages request handling and delegates complex operations to the Model.

- **View's Role**: Responsible for rendering the response to the user.

- **Handoff Process**: The Controller determines what to send as a response and calls an appropriate method to generate it.

- **View Rendering**:

  - Rails wraps views in a layout.

  - It may also include partial views for modularity.

- **Full-Blown Views**: When rendering a complete view, Rails manages additional processes like layout application and partial inclusion.


# 2. Creating Responses

- In Rails, controllers can create an HTTP response in three ways:

  - **render**: Creates a full response to send back to the browser.

  - **redirect_to**: Sends an HTTP redirect status code to the browser.

  - **head**: Creates a response consisting solely of HTTP headers.

## 2.1 Rendering by Default: Convention Over Configuration

- Rails follows the principle of "convention over configuration", meaning that:

   ```bash
    Controllers automatically render views with names matching valid routes.
    ```

- If no explicit render is used, Rails looks for an action_name.html.erb template in the controller's view path.

### Example: Default Rendering

**Controller** (BooksController):

```ruby
class BooksController < ApplicationController
end
```

**Routes** (config/routes.rb):

```ruby
resources :books
```

**View** (app/views/books/index.html.erb):

```ruby
<h1>Books are coming soon!</h1>
```

- When navigating to `/books`, Rails automatically renders `app/views/books/index.html.erb`.

### 2.1.1 Rendering Data from the Model

- To display data from the database:

**Updated Controller** (BooksController):

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

- Rails automatically renders `app/views/books/index.html.erb`.

**ERB Template to Display Books**:

```ruby
<h1>Listing Books</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Content</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= book.title %></td>
        <td><%= book.content %></td>
        <td><%= link_to "Show", book %></td>
        <td><%= link_to "Edit", edit_book_path(book) %></td>
        <td><%= link_to "Destroy", book, data: { turbo_method: :delete, turbo_confirm: "Are you sure?" } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>
<%= link_to "New book", new_book_path %>
```

### 2.1.2 Rendering Process

- The actual rendering is handled by `ActionView::Template::Handlers`.

- The file extension determines the template handler `(e.g., .erb for Embedded Ruby)`.

- This summarizes how Rails handles responses in controllers efficiently using conventions.

## 2.2 Using render

- The render method in Rails handles rendering content for the browser.

- It allows customization of rendering behavior, including:

  - Rendering default views

  - Rendering specific templates or files

  - Rendering inline code or nothing at all

  - Rendering text, JSON, or XML

  - Specifying content type or HTTP status

**`render_to_string`**

  - Returns a string representation of the rendered content instead of sending a response to the browser.

  - Accepts the same options as render.


### 2.2.1 Rendering an Action's View

- You can render a different template within the same controller using render:

```ruby
  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to(@book)
    else
      render "edit"
    end
  end
```

- If update fails, it renders the edit.html.erb template within the same controller.

**Alternative Syntax**

- You can use a symbol instead of a string and specify an HTTP status:

```ruby
  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to(@book)
    else
      render :edit, status: :unprocessable_entity
    end
  end
```

- `status: :unprocessable_entity` indicates a validation failure (HTTP 422).

### 2.2.2 Rendering an Action's Template from Another Controller

- In Rails, you can render a template from a different controller by specifying the full path relative to app/views.

**Usage**

- If you want to render a view from a different controller, use the full path:

```ruby
render "products/show"
```

- Rails detects the different controller because of the slash (/) in the path.

- You can also explicitly specify the template option:

```ruby
render template: "products/show"
```

- This approach was required in Rails 2.2 and earlier but is now optional.

**Example Scenario**

- If you're inside `AdminProductsController` located in `app/controllers/admin`, and you need to render a view from `app/views/products`, you can do:

```ruby
render "products/show"
```

- or explicitly:

```ruby
render template: "products/show"
```

**Key Takeaways**

- Use the full path relative to `app/views` when rendering from another controller.

- The embedded `slash (/)` signals Rails to look for the template in a different controller’s view directory.

- `:template` is an optional explicit way to define the view path.

### 2.2.3 Wrapping It Up

- Two Ways of Rendering:

  - Rendering the template of another action in the same controller

  - Rendering the template of another action in a different controller

- Both methods are variations of the same operation.

**Rendering `edit.html.erb` in `BooksController#update`**

- If the book update fails, the following render calls will all render the edit.html.erb template from views/books:

```ruby
render :edit
render action: :edit
render "edit"
render action: "edit"
render "books/edit"
render template: "books/edit"
```