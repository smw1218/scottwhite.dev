+++
date = '2022-07-19T12:00:00-08:00'
title = 'Single Model Approach in Go'
summary = 'Do you really need all that copying?'
+++
For many application APIs, the majority of your API calls end up being thin CRUD (create, read, update, delete) wrappers around a database record. This means you’ll often have a struct representing the database record for representation in your code. You’ll also need to marshal this data to the wire to return it for your API. In a microservices environment, you often also have an API client for that same API which parses the wire format back into a struct for usage. Many server architecture patterns recommend isolating these different concerns including having separate objects for all three places.

I had seen this pattern used in several places. I’d recently managed a team writing code to this pattern in Java. There were often bugs caused by forgetting to add a new field to one of the objects. It also required maintaining a lot of methods to copy fields from one representation to the other. I had talked to some Uber engineers and they did the same thing in their code for various reasons like the difficulty of coordinating client/server API updates across a large team or usage of gRPC generated structs that were difficult to make certain kinds of modifications. gRPC for Go will generate stubs using the same object by default for server and client but it’s not a good idea to modify that generated code for other purposes. I’ve also heard that some teams will generate their own clients from the proto files to lock down possible changes or in some attempt to “decouple” the client from the source server. This means a lot of structs all representing the same data object.

When at Tonal I saw the same pattern emerging, I questioned whether it was necessary to have multiple structs or if I could use the same one for everything. I always think it’s better to have a single source of truth so having a single struct was attractive to me. We were using gorm to wrap postgres and we have a simple JSON REST API, so we needed a DB model plus server and client for the API. Initially I was worried that there was something I was missing that would come back to bite us later if I bucked the common wisdom. But given our small team and my hope that this would prevent the types of errors I’d seen in the past, I took the risk and decided we’d only have one model struct.

Working within the system does seem a bit strange at first because the struct has tags for both gorm (database decorators like indexes and primary keys) and JSON. Each of these won’t be used in certain contexts; the other services doing a client call don’t know or care about how another service stores/fetches a record. And the database layer doesn’t care about JSON. Once we get got used to the pattern this structure has worked great for us. It completely removed boilerplate copy methods and having a single model struct meant that there was only one source of truth for the data.

In addition, we use gorm’s [AutoMigrate](https://pkg.go.dev/gorm.io/gorm#DB.AutoMigrate) feature which creates and modifies the database structure based on the fields in your struct. Adding a new field stored in the database and returned in the API is a one line change. We make use of the struct tags to occasionally hide fields from either the JSON serialization or storage in the DB.

The location of the models is also worth noting. We follow an organizational structure that I talked about more extensively [here](https://www.scottwhite.com/posts/go-project-structure/). The tl;dr is that we have a rule that we don’t allow imports of packages across microservices. The controller code that does server handlers and repository code that does database actions are owned by a microservice and they import the model structs from a top level shared package. The client code is in the same top-level package since clients are used across multiple microservices. Here’s an example:

```
workouts/            // business logic shared lib
    client.go        // client APIs for *Workout
    models.go        // contains Workout struct
cmd/
    workouts-service/
        main.go
        app/         
            setup.go      // gorm AutoMigrate for *workouts.Workout
        workouts/    
            controller.go // server APIs for *workouts.Workout
            repo.go       // DB access for *workouts.Workout
```

We also have many API’s that aren’t one to one with the database and in those cases we have separate models. But for the large number that are, this has worked wonderfully for the past 4 years with no drastic side effects. The solution is clean, simple and easy to maintain and it might be the right fit for your Go backend too.
