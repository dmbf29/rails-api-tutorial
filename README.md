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
<p><img width="114" alt="image" src="https://github.com/dmbf29/rails-api-tutorial/assets/25542223/86fe6250-b2ac-4fcc-bce5-1d4d2662035d"></p>

Data types:
- title -> string
- address -> string
- gmaps_url -> string
- picture -> string (⚠️ An external url, not using ActiveStorage)
- informations -> hash (⚠️ see how to create this below)
ie: `"informations": { "Mon": [ "08:00 \u2013 23:00" ], "Tue": [ "08:00 \u2013 23:00" ], ...`
- criterion -> array (⚠️ see how to create this below)
ie: `"criterion": [ "Stable Wi-Fi", "Power sockets", "Quiet", "Coffee", "Food" ]`

## Creating the Model
```
rails g model cafe title:string address:string gmaps_url:string picture:string informations:jsonb criterion:string
```
You'll notice that when we create the `informations` hash, we're actually using a `jsonb` type.
_You can see how this works in the [official documentaion](https://guides.rubyonrails.org/active_record_postgresql.html#json-and-jsonb)_.

And when we create the `criterion` array, we're actually specifying a string *at first*. But we'll have to update the migration (before we migrate) to indicate we're using an array:
```
t.string :criterion, array: true
```
_You can see how this works in the [official documentaion](https://guides.rubyonrails.org/active_record_postgresql.html#array)_.
