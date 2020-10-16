## Dependencies (Gems/packages)

## Configuration (environment variables/other stuff in config folder)

## Database
```rb
ActiveRecord::Schema.define(version: 20160119152016) do

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string   "content"
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "comments", ["post_id"], name: "index_comments_on_post_id"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "post_categories", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "post_categories", ["category_id"], name: "index_post_categories_on_category_id"
  add_index "post_categories", ["post_id"], name: "index_post_categories_on_post_id"

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.string   "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

```
## Models
```rb
class Category < ActiveRecord::Base
  has_many :post_categories
  has_many :posts, through: :post_categories
end
class PostCategory < ActiveRecord::Base
  belongs_to :post
  belongs_to :category
end
class Post < ActiveRecord::Base
  has_many :post_categories
  has_many :categories, through: :post_categories
  has_many :comments
  has_many :users, through: :comments
end
class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
end
class User < ActiveRecord::Base
  has_many :comments
  has_many :posts, through: :comments
end

```
## Views
nothing yet. (files but no content)
## Controllers
Categories#show
comments#create
posts#show,index,new,create
users#show
## Routes
restful routes (resources) for posts, comments, users and categories
```rb
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :posts
  resources :comments
  resources :users
  resources :categories
end

```

When you call build on a has_many, through association, it will create the join model in addition to the other model. 

Example:

```rb
@post = Post.create(title: "Feeling Groovy", content: "I'm feeling so groovy")
@cool = @post.categories.build(name: "Cool")

```

This line: `@post.categories.build(name: "Cool")` will create an instance of PostCategory as well as an instance of Category. When we save the post (`@post.save`), both of these instances will also be saved.

```rb
Post.last
  Post Load (1.7ms)  SELECT  "posts".* FROM "posts" ORDER BY "posts"."id" DESC LIMIT ?  [["LIMIT", 1]]
 => #<Post id: 1, title: "Feeling Groovy", content: "I'm feeling so groovy", created_at: "2020-10-15 22:21:40", updated_at: "2020-10-15 22:21:40"> 
2.6.1 :011 > Category.last
  Category Load (0.2ms)  SELECT  "categories".* FROM "categories" ORDER BY "categories"."id" DESC LIMIT ?  [["LIMIT", 1]]
 => #<Category id: 1, name: "Cool", created_at: "2020-10-15 22:21:41", updated_at: "2020-10-15 22:21:41"> 
2.6.1 :012 > PostCategory.last
  PostCategory Load (0.4ms)  SELECT  "post_categories".* FROM "post_categories" ORDER BY "post_categories"."id" DESC LIMIT ?  [["LIMIT", 1]]
 => #<PostCategory id: 1, post_id: 1, category_id: 1, created_at: "2020-10-15 22:21:41", updated_at: "2020-10-15 22:21:41"> 
2.6.1 :013 > 
```

If you need to clean up some of your records in the database that are missing foreign keys, you can do something like this in the rails console:

```rb
Comment.where(user_id:nil).update_all(user_id:1)
```

## Nested Form means what things for our Model View and Controller?
In our example we're adding a nested form for a Category to our new Post form.
### Model
categories_attributes= method (custom attribute writer)
or 
accepts_nested_attributes_for :categories
#### We know which we want to use by asking these questions:
Do I care about duplicates? Is this a one-to-many relationship or is it many-to-many? Do I need find_or_create_by?
If yes to any of these, pick the custom attribute writer instead of accepts_nested_attributes_for
### View 
f.fields_for :categories, Category.new 
the argument has to match the method name (before _attributes) in the model.
### Controller
```rb
def post_params
  params.require(:post).permit(:title, :content, category_ids:[], categories_attributes: [:name])
end
```
The categories_attributes param has to be the last key in the permitted params list and it will point to a value of an array of the field names inside of the fields_for in our form.