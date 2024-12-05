+++
date = '2022-06-28T12:00:00-08:00'
title = 'Go Project Structure'
summary = 'Structure for your backend Go repository.'
+++
Organizing go code in a big project can be hard. [Go’s standard package naming conventions](https://go.dev/blog/package-names) are great, but the examples are simplistic and relate more to library code. With so many companies using Go for their backend, I’m surprised by how few examples there are of package/folder organization for a big server project. At Tonal, we have a monorepo supporting many microservices and, after many iterations over the past four years, I think we finally have a good basic structure that will serve us well going forward. Tonal produces a connected strength training device, so my business logic examples will be workout related.

We have about 40 microservices, each of which has related business logic specific to the APIs they support. To organize these together, the service compilation units are placed in a `cmd` subdirectory under our root. Each service directory follows the pattern `{serviceName}-service`. This isn’t a valid package name on purpose because this folder only contains `main.go` using the `main` package. We have a convention that all services should start in local development from here with just `go run main.go`. This directory also has non-go service specific setup like a `Dockerfile` and a `k8s` directory for Kubernetes config.

The service directory also has an `app` package that’s responsible for the service configuration and boot-up. This package has a common name across all microservices to provide a common starting point for initializing dependencies and registering the routes supported by the service. It also keeps the `main.go` compact as most initialization is in the service `app` package. Having static naming conventions for these allows for code generation of a new service with our standard boot-strapping and CI/CD configurations.

Initially, inside each service directory we had a `controllers` directory that contain our API handlers, and often a `repos` directory containing database access code. I now think this convention was a mistake. As the code has grown, these directories have gotten bigger and bigger and I feel like they’re now too generic and mix concerns badly in the same way a generic `utils` package does. One of my coworkers came up with a better solution. He created packages based on functionality instead of generic role.

Instead of:

```
controllers/
    workouts.go
repos/
     workouts.go
```
Do this:

```
workouts/ 
    controllers.go
    repos.go
```
This change gives the exact same information at the file browsing level, but it makes the code simpler because there isn’t a generic package prefix. For example, a repo method `FetchWorkout` called from the controller package would be `repos.FetchWorkout` but is just `FetchWorkout` when the code is in the same package. This more idiomatic for Go. Often the code organized this way is only used within the package and doesn’t need to be exported which allows for easier modification.

Any code that is shared across services gets put into top-level packages at the root based on functionality. Most of these packages have names specific to our company’s business logic or features, for example: `workouts`, `weights` and `leaderboard`. Others are specific utility packages like `service` which provides common utilities for booting up a microservice and registering API endpoints with standard monitoring and middleware. Other examples are `response` which contains helpers for standard API responses and `pg` which allows for common configuration of our postgresql DB connection.

Being microservice-based, we need to have shared clients to call other services. This means we often have packages at the top level that match the service name that contains the client code. This was a big reason for pushing the service directories down into the `cmd` directory to minimize navigation confusion. We have a policy that no service can import packages from another one, so if any code needs to be shared, it must be hoisted into the top-level directories.

Here is a complete example of our top-level git repo:

```
cmd/
    workouts-service/
        main.go
        app/         // service setup
            setup.go
        workouts/    // business logic
            controller.go
            repo.go
            
        k8s/         // kubernetes config
        Dockerfile    // deployment packaging
    media-service/
        ...          // same layout as workouts-service
workouts/            // business logic shared lib
    client.go
    models.go
response/           // generic shared lib
    errors.go
pg/                 // generic shared lib
    connection.go
```

This organization is simple and intentionally flat to remove unnecessary directory taxonomy (no `pkg` directory). I think many companies may use a similar structure but I think every company’s project will look very different. There are very few static names in the hierarchy and following this method requires choosing good names based on your business logic.

It’s much easier to communicate static names that can be used across problem domains than to communicate using good names that are application specific. Ruby on Rails uses folder names like `models` or `controllers`. We used this method early on but it got overwhelmingly messy very quickly because of the way package names are used in the code. It also mixed domains with code for separate features all mixed together. Having generic package names end up being boilerplate that conveys little information. The only generic package used here is the `app` package which is only used from `main.go` so it doesn’t litter the business logic code.

Even the examples I used in this post aren’t real because the actual names are so domain specific as to not be understood to a broad audience. I’m lucky that I work on a product where most people least understand what a workout is. Each developer knows their company’s domain best and should choose names in the structure that reflect those concerns.
