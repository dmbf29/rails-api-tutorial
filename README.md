# Rails API Tutorial - Cafes Example

## Create the application
```
rails new NAME_OF_YOUR_APPLICATION -d postgresql --api
```
With the `--api` flag, there are 3 main differences:
- Configure your application to start with a more limited set of middleware than normal. Specifically, it will not include any middleware primarily useful for browser applications (like cookies support) by default.
- Make `ApplicationController` inherit from `ActionController::API` instead of `ActionController::Base`. As with middleware, this will leave out any Action Controller modules that provide functionalities primarily used by browser applications.
- Configure the generators to skip generating views, helpers, and assets when you generate a new resource.

You can read more about the changes in the [official documentation](https://guides.rubyonrails.org/api_app.html).


Also, the `-d` makes sure we start with a postgresql database (instead of the default sqlite)

## Designing the DB
We're going to keep this tutorial simple. We'll just have a `cafe` model. Based around [this information](https://gist.github.com/yannklein/5d8f9acb1c22549a4ede848712ed651a), which we'll be seeding into our app eventually.
<p>
  <img width="110" alt="image" src="https://github.com/dmbf29/rails-api-tutorial/assets/25542223/d09c4e6c-a328-4bcc-9407-f2a971535c47">
</p>

Data types:
- title `->` string
- address `->` string
- gmaps_url `->` string
- picture `->` string (⚠️ We're not using ActiveStorage for simplicity sake).
- informations `->` hash (⚠️ see how to create this below)

ie: `"informations": { "Mon": [ "08:00 - 23:00" ], "Tue": [ "08:00 - 23:00" ], ...`
- criteria `->` array (⚠️ see how to create this below)

ie: `"criteria": [ "Stable Wi-Fi", "Power sockets", "Quiet", "Coffee", "Food" ]`

## Creating the Model
Create the DB before the model
```
rails db:create
```

⚠️ Small warning about pluralization in Rails 😅
- The pluralization is built in to handle things like `person` => `people` and `sky` => `skies` etc.
- But when we generate a `cafe` model in Rails, it creates a table called `caves`.... which is obviously **not** what we want. Here is a [StackOverflow answer on how to fix it](https://stackoverflow.com/a/10861810/8278088)

So let's go into our `config/initializers/inflections.rb` and add this:
```
ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural "cafe", "cafes"
end
```

Then create the model
```
rails g model cafe title:string address:string gmaps_url:string picture:string informations:jsonb criteria:string
```

You'll notice that when we create the `informations` hash, we're actually using a `jsonb` type.

_You can see how this works in the [official documentaion](https://guides.rubyonrails.org/active_record_postgresql.html#json-and-jsonb)_.

And also when we create the `criteria` array, we're actually specifying a string **at first**. But we'll have to update the migration (before we migrate) to indicate we're using an array:
```
t.string :criteria, array: true
```
_You can see how this works in the [official documentaion](https://guides.rubyonrails.org/active_record_postgresql.html#array)_.

Then run the migration and our DB should be ready to go.
```
rails db:migrate
```

## Setting up the Model
It's up to you at this point, but we'll add two validations on the `cafe` model so that we need at least a `title` and
