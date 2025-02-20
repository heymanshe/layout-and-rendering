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

