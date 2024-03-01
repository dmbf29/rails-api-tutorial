# Rails API Tutorial - Cafes Example

## Create the application
```
rails new NAME_OF_YOUR_APPLICATION -d postgresql --api
```
With the `--api` flag, there are 3 main differences:
- Configure your application to start with a more limited set of middleware than normal. Specifically, it will not include any middleware primarily useful for browser applications (like cookies support) by default.
- Make `ApplicationController` inherit from `ActionController::API` instead of `ActionController::Base`. As with middleware, this will leave out any Action Controller modules that provide functionalities primarily used by browser applications.
- Configure the generators to skip generating views, helpers, and assets when you generate a new resource.

Also, the `-d` makes sure we start with a postgresql database (instead of the default sqlite)

## Designing the DB
We're going to keep this tutorial simple. We'll just have a `cafe` model. Based around [this information](https://gist.github.com/yannklein/5d8f9acb1c22549a4ede848712ed651a), which we'll be seeding into our app eventually.
<p><img width="114" alt="image" src="https://github.com/dmbf29/rails-api-tutorial/assets/25542223/86fe6250-b2ac-4fcc-bce5-1d4d2662035d"></p>
