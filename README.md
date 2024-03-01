# Rails API Tutorial - Cafes Example

1. Create the application
```
rails new NAME_OF_YOUR_APPLICATION -d postgresql --api
```
With the `--api` flag, there are 3 main differences:
- Configure your application to start with a more limited set of middleware than normal. Specifically, it will not include any middleware primarily useful for browser applications (like cookies support) by default.
- Make `ApplicationController` inherit from `ActionController::API` instead of `ActionController::Base`. As with middleware, this will leave out any Action Controller modules that provide functionalities primarily used by browser applications.
- Configure the generators to skip generating views, helpers, and assets when you generate a new resource.

Also, the `-d` makes sure we start with a postgresql database (instead of the default sqlite)
