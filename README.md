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

### 2.2.4 Rendering Inline

- `render inline` allows rendering ERB directly within the method call.

```bash
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

- Not recommended as it violates `MVC principles`.

- You can specify Builder instead of ERB using type: :builder.

```bash
render inline: "xml.p {'Horrid coding practice!'}", type: :builder
```

### 2.2.5 Rendering Text

- `render plain` sends pure text without markup.

```bash
render plain: "OK"
```

- Useful for AJAX or API responses.

- To include the layout, use `layout: true` and a `.text.erb` layout file.

### 2.2.6 Rendering HTML

- `render html` sends HTML back to the browser.

```bash
render html: helpers.tag.strong("Not Found")
```

- HTML entities are escaped unless composed with `html_safe`.

- Prefer using a view template for complex `HTML`.

### 2.2.7 Rendering JSON

- `render json` automatically calls `to_json` on objects.

```bash
render json: @product
```

### 2.2.8 Rendering XML

- `render xml` automatically calls `to_xml` on objects.

```bash
render xml: @product
```

### 2.2.9 Rendering JavaScript

```bash
render js sends JavaScript to the browser.

render js: "alert('Hello Rails');"
```

### 2.2.10 Rendering Raw Body

- `render body` sends content without specifying content type.

```bash
render body: "raw"
```

- Default response type is `text/plain`.

### 2.2.11 Rendering Raw Files

- `render file` renders a raw file `(without ERB processing)`.

```bash
render file: "#{Rails.root}/public/404.html", layout: false
```

- **Security concern**: Avoid user input for file paths.

- **Alternative**: `send_file` is often a better choice.

### 2.2.12 Rendering Objects

- `render` an object calls `render_in` on the object.

```ruby
class Greeting
  def render_in(view_context)
    view_context.render html: "Hello, World"
  end
  def format
    :html
  end
end
render Greeting.new  # => "Hello, World"
```

- **Alternative**: Use `renderable:` option.

```bash
render renderable: Greeting.new
```

### 2.2.13 Options for render 

- **`:content_type`**

- **`:layout`**

- **`:location`**

- **`:status`**

- **`:formats`**

- **`:variants`**

#### 2.2.13.1 The `:content_type` Option

- By default, Rails serves responses as `text/html` (or application/json for `:json` and application/xml for `:xml`). You can specify a different content type:

```ruby
render template: "feed", content_type: "application/rss"
```

#### 2.2.13.2 The `:layout` Option

- Controls the layout used in rendering:

  - Use a specific layout:

```ruby
render layout: "special_layout"
```

  - Render without a layout:

```ruby
render layout: false
```

#### 2.2.13.3 The `:location` Option

- Sets the HTTP Location header:

```ruby
render xml: photo, location: photo_url(photo)
```

#### 2.2.13.4 The `:status` Option

- Overrides the default HTTP response status:

```ruby
render status: 500
render status: :forbidden
```

- Rails understands both numeric codes and symbols:

`200 :ok`

`201 :created`

`404 :not_found`

`500 :internal_server_error`

- If a non-content status (100-199, 204, 205, or 304) is used, content will be dropped.

#### 2.2.13.5 The `:formats` Option

- Specifies response formats:

```ruby
render formats: :xml
render formats: [:json, :xml]
```

- Raises `ActionView::MissingTemplate` if the specified format template does not exist.

#### 2.2.13.6 The :variants Option

- Allows specifying template variations:

```ruby
render variants: [:mobile, :desktop]
```

- Rails searches for templates in this order:

```ruby
app/views/home/index.html+mobile.erb

app/views/home/index.html+desktop.erb

app/views/home/index.html.erb
```

- Alternatively, set variants in the controller:

```ruby
def index
  request.variant = determine_variant
end

private

def determine_variant
  variant = :mobile if session[:use_mobile]
  variant
end
```

- Raises `ActionView::MissingTemplate` if no matching template is found.


### 2.2.14 Finding Layouts

- Rails looks for a layout file in `app/views/layouts` matching the controller name.

- If not found, it defaults to `application.html.erb` or `application.builder`.

- `.erb` layout is prioritized over `.builder` if both exist.

#### 2.2.14.1 Specifying Layouts for Controllers

- Override default layout using layout declaration in controllers.

```ruby
class ProductsController < ApplicationController
  layout "inventory"
end
```

- Set a global layout in `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  layout "main"
end
```

#### 2.2.14.2 Choosing Layouts at Runtime

- Use a method to dynamically select a layout:

```ruby
class ProductsController < ApplicationController
  layout :products_layout

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end
end
```

- Use a `Proc` for inline logic:

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

#### 2.2.14.3 Conditional Layouts

- Use `:only` and `:except` options to limit layout usage:

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

#### 2.2.14.4 Layout Inheritance

- Layouts cascade down in the hierarchy.

- More specific layouts override general ones.

```ruby
class ApplicationController < ActionController::Base
  layout "main"
end

class ArticlesController < ApplicationController
end

class SpecialArticlesController < ArticlesController
  layout "special"
end

class OldArticlesController < SpecialArticlesController
  layout false
  
  def show
    @article = Article.find(params[:id])
  end

  def index
    @old_articles = Article.older
    render layout: "old"
  end
end
```

**Layout Usage**:

- Default: `main`

- `SpecialArticlesController#index`: `special`

- `OldArticlesController#show`: No layout

- `OldArticlesController#index`: `old`

#### 2.2.14.5 Template Inheritance

- If a template/partial isn't found, Rails looks up the controller hierarchy.

- Example hierarchy:

```bash
app/views/admin/products/

app/views/admin/

app/views/application/
```

- Shared partials can be placed in `app/views/application/`.

```bash
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
There are no items in this list <em>yet</em>.
```

### 2.2.15 Avoiding Double Render Errors

#### Understanding the Error

- Rails developers may encounter the error:

```bash
Can only render or redirect once per action
```

- This occurs due to a misunderstanding of how render works. If multiple render calls are executed within the same action, Rails will throw an error.

- Example of Double Render Error

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

#### Why This Fails
- If `@book.special?` is `true`, `render action: "special_show"` is executed.
- However, execution continues, and `render action: "regular_show"` is also called, causing an error.

#### Solution: Prevent Multiple Renders
A simple way to avoid this error is by using `return` to stop execution after the first `render`:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
    return
  end
  render action: "regular_show"
end
```

- Alternative Approach: Rely on Implicit Rendering

- Rails automatically renders the default template if render is not explicitly called. The following works without errors:

```ruby
def show
  @book = Book.find(params[:id])
  render action: "special_show" if @book.special?
end
```

- How This Works:

```bash
If @book.special? is true, special_show is rendered.
```

- Otherwise, Rails will implicitly render `show.html.erb`.

## 2.3 Using redirect_to

- `redirect_to` sends a new request to a different URL.

```ruby
redirect_to photos_url
```

- `redirect_back` returns the user to the previous page using `HTTP_REFERER`.

```ruby
redirect_back(fallback_location: root_path)
```

- `redirect_to` and `redirect_back` do not halt execution immediately; use `return` to stop further execution if needed.

### 2.3.2 Redirect Status Codes

- By default, `redirect_to` uses HTTP status code **302 (temporary redirect)**.

- To specify a different status, use the `:status` option:

```ruby
redirect_to photos_path, status: 301  # Permanent redirect
```

- Accepts both numeric and symbolic header designations.

### 2.3.3 Difference Between `render` and `redirect_to`

- `redirect_to` instructs the browser to make a new request.

- `render` does not trigger a new request; it renders the specified template within the current request.

- Example of render Issue:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"  # Problem: @books is not set
  end
end
```

- If `@book` is `nil`, rendering index will fail because `@books` is not initialized.

**Correcting with `redirect_to`**:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

- This triggers a new request for `index`, ensuring `@books` is properly set.

- Downside: Requires a round-trip request, adding latency.

**Alternative Using `render` with `flash.now`**:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "Your book was not found"
    render "index"
  end
end
```

- This avoids a round-trip request.

- The `flash.now[:alert]` message is displayed without persisting across requests.

## 2.4 Using `head` to Build Header-Only Responses

- The `head` method in Rails is used to send responses containing only HTTP headers without a response body. It accepts:

  - An HTTP status code (number or symbol)

  - An optional hash of header names and values


**Sending an Error Header**

```bash
head :bad_request
```

**Response Headers**:

```bash
HTTP/1.1 400 Bad Request
Connection: close
Date: <timestamp>
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: <execution_time>
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

**Sending a Header with Location**

```ruby
head :created, location: photo_path(@photo)
```

**Response Headers**:

```bash
HTTP/1.1 201 Created
Connection: close
Date: <timestamp>
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: <execution_time>
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

**Key Takeaways**

- `head` allows sending HTTP headers without a response body.

- Supports HTTP status codes (e.g., `:bad_request`, `:created`).

- Can include additional headers like location.

- Useful for API responses, redirects, and error handling.


# 3. Structuring Layouts in Rails

- When Rails renders a view, it combines the view with the current layout. Three primary tools help structure layouts:

  - **Asset Tags**

  - **yield and `content_for`**

  - **Partials**

## 3.1 Asset Tag Helpers

- Asset tag helpers generate HTML linking views to various assets like JavaScript, stylesheets, images, videos, and audios. These do not verify asset existence but assume correctness.

**Available Asset Tag Helpers**

- `auto_discovery_link_tag` (for RSS, Atom, JSON feeds)

- `javascript_include_tag` (for JavaScript files)

- `stylesheet_link_tag` (for CSS files)

- `image_tag` (for images)

- `video_tag` (for videos)

- `audio_tag` (for audios)

### 3.1.1 Linking to Feeds with `auto_discovery_link_tag`

```ruby
<%= auto_discovery_link_tag(:rss, {action: "feed"}, {title: "RSS Feed"}) %>
```

- Options:

- `:rel` - Default is "alternate".

- `:type` - Explicit MIME type.

- `:title` - Defaults to uppercase type (e.g., "ATOM", "RSS").

### 3.1.2 Linking to JavaScript Files with `javascript_include_tag`

```ruby
<%= javascript_include_tag "main" %>
```

- Uses the **Asset Pipeline** to serve files from `app/assets`, `lib/assets`, or `vendor/assets`.

- Multiple files can be included:

```ruby
<%= javascript_include_tag "main", "columns" %>
```

- External JavaScript:

```ruby
<%= javascript_include_tag "http://example.com/main.js" %>
```

### 3.1.3 Linking to CSS Files with `stylesheet_link_tag`

```ruby
<%= stylesheet_link_tag "main" %>
```

- Uses the Asset Pipeline.

- Multiple stylesheets:

```ruby
<%= stylesheet_link_tag "main", "columns" %>
```

- External CSS:

```ruby
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

- `Media-specific stylesheets:

```ruby
<%= stylesheet_link_tag "main_print", media: "print" %>
```

### 3.1.4 Linking to Images with `image_tag`

```ruby
<%= image_tag "header.png" %>
```

- Default directory: `public/images`.

- Supports paths and additional options:

```ruby
<%= image_tag "icons/delete.gif", height: 45 %>
```

- Alternative text defaults to the capitalized filename without an extension.

- Supports `size`:

```ruby
<%= image_tag "home.gif", size: "50x20" %>
```

- HTML attributes:

```ruby
<%= image_tag "home.gif", alt: "Go Home", id: "HomeImage", class: "nav_bar" %>
```

### 3.1.5 Linking to Videos with `video_tag`

```ruby
<%= video_tag "movie.ogg" %>
```

- Default directory: `public/videos`.

- Options:

  - `poster`: Placeholder image before playing.

  - `autoplay: true`: Auto-plays video.

  - `loop: true`: Loops video.

  - `controls: true`: Shows video controls.

```ruby
<%= video_tag "movie.ogg", controls: true, autoplay: true, loop: true %>
```

- Multiple video sources:

```ruby
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

### 3.1.6 Linking to Audio Files with `audio_tag`

```ruby
<%= audio_tag "music.mp3" %>
```

- Default directory: `public/audios`.

- Options:

  - `autoplay: true`: Auto-plays audio.

  - `controls: true`: Shows audio controls.

```ruby
<%= audio_tag "music.mp3", controls: true, autoplay: true %>
```

