# Rails API Tutorial
### Cafes Example

Note: the slide version of this workshop is available [here](https://slides.trouni.com/?src=https://raw.githubusercontent.com/dmbf29/rails-api-tutorial/master/README.md#/).


## Goal - Back End
We will build a Rails application that acts solely as an API. Instead of displaying HTML pages, it'll render JSON.
<p><img width="600" alt="image" src="https://github.com/dmbf29/rails-api-tutorial/assets/25542223/d701384d-f4e4-42fa-8ced-7dd070ec70b5"></p>


## Goal - Front End
In this [separate workshop](https://github.com/yannklein/react-workshop-ref-feb2024/), we'll build a [React application](https://yannklein.github.io/react-workshop-ref-feb2024/) to consume this API.
<p>
<img width="600" alt="image" src="https://github.com/dmbf29/rails-api-tutorial/assets/25542223/252a1b9b-6a94-482e-9ccc-015d4f1fd302">
</p>


## Prerequisites
- This workshop is going to be breaking down the steps of how turn a Rails app into a simple API.

- We'll be going under the assumption, we've built previous Rails apps before.

- I suggest to follow the steps to create a new app in the README instead of trying to clone it.


## Create the application
```sh
rails new NAME_OF_YOUR_APPLICATION -d postgresql --api
```
With the `--api` flag, there are 3 main differences:
- Configure your application to start with a more limited set of middleware than normal. Specifically, it will not include any middleware primarily useful for browser applications (like cookies support) by default.
- Make `ApplicationController` inherit from `ActionController::API` instead of `ActionController::Base`. As with middleware, this will leave out any Action Controller modules that provide functionalities primarily used by browser applications.
- Configure the generators to skip generating views, helpers, and assets when you generate a new resource.

You can read more about the changes in the [official documentation](https://guides.rubyonrails.org/api_app.html).


## Designing the DB
We're going to keep this tutorial simple. We'll just have a `cafe` model. Based around [this information](https://gist.github.com/yannklein/5d8f9acb1c22549a4ede848712ed651a), which we'll be seeding into our app eventually.

<p>
  <img width="108" alt="image" src="https://github.com/dmbf29/rails-api-tutorial/assets/25542223/daa380d6-26da-4e1f-8e66-40293899a571">
</p>

- `title`: string
- `address`: string
- `picture`: string (⚠️ We're not using ActiveStorage for simplicity sake).
- `hours`: hash (⚠️ see how to create this below)
- `criteria`: array (⚠️ see how to create this below)


## Creating the Model
Create the DB before the model
```sh
rails db:create
```


⚠️ Small warning about pluralization in Rails 😅
- The pluralization is built in to handle things like `person` => `people` and `sky` => `skies` etc.
- But when we generate a `cafe` model in Rails, it creates a table called `caves`.... which is obviously **not** what we want. Here is a [StackOverflow answer on how to fix it](https://stackoverflow.com/a/10861810/8278088)

So let's go into our `config/initializers/inflections.rb` and add this:
```rb
ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural "cafe", "cafes"
end
```


Then create the model
```sh
rails g model cafe title:string address:string picture:string hours:jsonb criteria:string
```


You'll notice that when we create the `hours` hash, we're actually using a `jsonb` type.

_You can see how this works in the [official documentaion](https://guides.rubyonrails.org/active_record_postgresql.html#json-and-jsonb)_.


And also when we create the `criteria` array, we're actually specifying a string **at first**. But we'll have to update the migration (before we migrate) to indicate we're using an array:
```rb
t.string :criteria, array: true
```
_You can see how this works in the [official documentaion](https://guides.rubyonrails.org/active_record_postgresql.html#array)_.


Then run the migration and our DB should be ready to go.
```sh
rails db:migrate
```


## Setting up the Model
It's up to you at this point, but we'll add three validations on the `cafe` model so that we need at least a `title` and `address` in order to create one. And also a uniqueness so that the same cafe at the same address can't be recreated.

```rb
# cafe.rb
validates :title, presence: true
validates :address, presence: true
validates :title, uniqueness: { scope: :address }
```


## Seeds
We were basing our data on around [this information](https://gist.github.com/yannklein/5d8f9acb1c22549a4ede848712ed651a) already so we've got a JSON that we can use in our seeds.

1. We'll open that link using `open-uri`
2. Turn the JSON result into a Ruby array
3. Iterate over the array and create an instance of a `cafe` for each hash in the array.


The point of this workshop is not how to seed the DB, so the code is already set in our `db/seeds.rb` file.
```rb
require 'open-uri'

puts "Removing all cafes from the DB..."
Cafe.destroy_all
puts "Getting the cafes from the JSON..."
seed_url = 'https://gist.githubusercontent.com/yannklein/5d8f9acb1c22549a4ede848712ed651a/raw/3daec24bcd833f0dd3bcc8cee8616a731afd1f37/cafe.json'
# Making an HTTP request to get back the JSON data
json_cafes = URI.open(seed_url).read
# Converting the JSON data into a ruby object (this case an array)
cafes = JSON.parse(json_cafes)
# iterate over the array of hashes to create instances of cafes
cafes.each do |cafe_hash|
  puts "Creating #{cafe_hash['title']}..."
  Cafe.create!(
    title: cafe_hash['title'],
    address: cafe_hash['address'],
    picture: cafe_hash['picture'],
    criteria: cafe_hash['criteria'],
    hours: cafe_hash['hours']
  )
end
puts "... created #{Cafe.count} cafes! ☕️"
```


Run the seeds `rails db:seed` and have a look in the `rails console` to see our cafes.


## Routes
If this is your first time building an API the routing is going to look a bit different from normal CRUD routes inside of a Rails app. We're going to add the word `api` in our route but also version it. So that if we end up updating the API, we dont have to break the old flow for apps relying on it. We can just shift to the second version.

So our user stories with routes:
- I can see all cafes
```
get '/api/v1/cafes'
```

- I can create a cafe
```
post '/api/v1/cafes'
```


How to namespace in our `routes.rb`
```rb
namespace :api, defaults: { format: :json } do
  namespace :v1 do
    resources :cafes, only: [ :index, :create ]
  end
end
```

Here we're also saying to expect json (since it's an API) instead of the normal HTML flow.


## Controllers
Now we need to create the `cafes_controller` but we're going to create one specifically for `v1` of our `api`. This gives us flexibility later on to create a separate controller for the next version.

To generate
```sh
rails g controller api/v1/cafes
```

This creates our controller. But also, it creates a folder called `api` inside of our `controllers` folder. Then another one called `v1` inside of that.
<p>
  <img width="305" alt="image" src="https://github.com/dmbf29/rails-api-tutorial/assets/25542223/57ccf834-d805-403c-9f85-82a40886f410">
</p>


## Controller Actions

### Index
Let's start with the index. It will follow normal Rails CRUD to pull all of the cafes from the DB.
```rb
def index
  @cafes = Cafe.all
end
```

If we allow users to search for cafes by their `title` in our app, we can add that into our action as well:
```rb
def index
  if params[:title].present?
    @cafes = Cafe.where('title ILIKE ?', "%#{params[:title]}%")
  else
    @cafes = Cafe.all
  end
end
```


**BUT**, this is the biggest difference from building an API compared to one with HTML views. Instead of rendering HTML, we're going to render JSON.
```rb
def index
  if params[:title].present?
    @cafes = Cafe.where('title ILIKE ?', "%#{params[:title]}%")
  else
    @cafes = Cafe.all
  end
  # Putting the most recently created cafes first
  render json: @cafes.order(created_at: :desc)
end
```


Now let's test out the endpoint. If we want to see our routes, we can check with `rails routes`.
This tells us to trigger our `cafes#index` action, we need to type `/api/v1/cafes` after our localhost.

Launch a `rails s` and check it out in the browser. You should be seeing JSON (intead of HTML).


### Create
Our create action is going to look exactly like a normal CRUD create action, except for when an error occurs. Instead of rerendering a form like we would in HTML, we'll respond back with the error inside of the JSON response:
```rb
render json: { error: @cafe.errors.messages }, status: :unprocessable_entity
```


So our full `create` controller action will look something like:
```rb
def create
  @cafe = Cafe.new(cafe_params)
  if @cafe.save
    render json: @cafe
  else
    render json: { error: @cafe.errors.messages }, status: :unprocessable_entity
  end
end

private

def cafe_params
  params.require(:cafe).permit(:title, :address, :picture, :address, hours: {}, criteria: [])
end
```


ℹ️ If you've added or changed any of the attributes for your model, make sure to update the strong parameters to match.


##### Testing the create
⚠️ Now how can we test this create action? We **can't** test it by typing a URL in the browser. We need to send a `POST` request instead of a `GET`. And we don't have an HTML form either. The easiest way to test this endpoint would be to use [Postman](https://www.postman.com/). In Postman, we'll need to make sure we're sending a `POST` to the correct address, but also sending the correct params.


We'll want our request to look like this:
<p>
<img width="1383" alt="image" src="https://github.com/dmbf29/rails-api-tutorial/assets/25542223/9f640d69-aecb-417e-af64-ad204651125e">
</p>


Or just the request code:

```json
{
  "cafe": {
    "title": "Le Wagon Tokyo",
    "address": "2-11-3 Meguro, Meguro City, Tokyo 153-0063",
    "picture": "https://www-img.lewagon.com/wtXjAOJx9hLKEFC89PRyR9mSCnBOoLcerKkhWp-2OTE/rs:fill:640:800/plain/s3://wagon-www/x385htxbnf0kam1yoso5y2rqlxuo",
    "criteria": ["Stable Wi-Fi", "Power sockets", "Coffee", "Food"],
    "hours": {
      "Mon": ["10:30 – 18:00"],
      "Tue": ["10:30 – 18:00"],
      "Wed": ["10:30 – 18:00"],
      "Thu": ["10:30 – 18:00"],
      "Fri": ["10:30 – 18:00"],
      "Sat": ["10:30 – 18:00"]
    }
  }
}
```


### CORS
CORS == Cross-origin resource sharing (CORS)
A nice explanation can be found in [this article](https://www.stackhawk.com/blog/rails-cors-guide/). In summary:
> CORS is an HTTP-header based security mechanism that defines who’s allowed to interact with your API. CORS is built into all modern web browsers, so in this case the “client” is a front-end of the application.
>
> In the most simple scenario, CORS will block all requests from a different origin than your API. “Origin” in this case is the combination of protocol, domain, and port. If any of these three will be different between the front end and your Rails application, then CORS won’t allow the client to connect to the API.
>
> So, for example, if your front end is running at https://example.com:443 and your Rails application is running at https://example.com:3000, then CORS will block the connections from the front end to the Rails API. CORS will do so even if they both run on the same server.


So the **TL;DR** is that we have to enable our front-end to access our back-end in 2 steps:
1. Uncomment `gem "rack-cors"` in the GEMFILE, then `bundle install`
2. Go to `config/initializers/cors.rb` and specify from which URL (and which actions) that you are willing to accept requests

_For example:_
```rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://example.com:80'
    resource '/orders',
      :headers => :any,
      :methods => [:post]
  end
end
```


Or to just blindly allow all (only for now)
```rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :patch, :put]
  end
end
```


## Last Feature
We've "tagged" our cafes with certain criteria ie: `wifi`, `outlets`, `coffee` etc.
Let's create an end-point for our [front-end](https://yannklein.github.io/react-workshop-ref-feb2024/) so that we can display all of these criteria.


### Criteria Route
Add in a criteria index inside our our namespaced routes.
```rb
namespace :api, defaults: { format: :json } do
  namespace :v1 do
    resources :cafes, only: [ :index, :create ]
    resources :criteria, only: [ :index ]
  end
end
```


### Criteria Controller
Generate controller
```sh
rails g controller api/v1/criteria
```


### Criteria Controller Action
We don't actually have a criteria model so we're going to pull all of the criteria from our `cafe`s using the `.pluck` and `.flatten` methods. Then make sure we're not duplicating any using the `.uniq` method:
```rb
def index
  @criteria = Cafe.pluck(:criteria).flatten.uniq
  render json: @criteria
end
```

We can test it out by visiting `/api/v1/criteria` in the browser which should return a JSON array of our criteria.


## Going Further
- Adding users and Pundit 👉 [Le Wagon student tutorial](https://kitt.lewagon.com/knowledge/tutorials/rails_api)
- Adding ActiveStorage and Cloudinary 👉 [Setup instructions](https://doug-berkley.notion.site/Heroku-Cloudinary-Checklist-bb68c46ef8ad42fea97924c8c338aaf7)
- Using JBuilder for JSON views 👉  `git checkout jbuilder`
- Writing tests 👉 [Setup RSpec](https://github.com/Naokimi/testing_with_rspec/tree/master), Video [part 1](https://youtu.be/YE16i6zouow) and [part 2](https://youtu.be/Q9U0p89Lqp4)
