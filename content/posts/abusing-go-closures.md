+++
date = '2025-03-03T09:12:43-08:00'
title = 'Abusing Go Closures'
summary = 'Please try named functions first'
featured_image='/img/funcfuncfuncfunc.png'
+++
I frequently see the overuse of function literals and [closures](https://en.wikipedia.org/wiki/Closure_(computer_programming)) in Go. If you want to write more readable Go code with less bugs, try getting rid of some of your unecessary closures. Here are some of the common patterns I've seen and how to write them in a more clear and readable way.

tl;dr If you're reaching for a closure, try to use a named function instead.

### Stop Wrapping and Just Call the Function

I've seen this one quite a lot:

```go
go func() {
    x.Run(param)
}()
```

This happens often when developers use `go` or `defer`. This should be rewritten to remove the closure:

```go
go x.Run(param)
```

This doesn't seem to be particularly damaging at first glance, but I wrote a [reaction article to concurrency bugs at Uber](/posts/concurrency-in-go-is-not-magic/) where the misuse of closures was a primary root cause. In the first example, the variable param is "captured" by the closure. It's difficult to see that if it changes later, `x.Run` will get the updated value. In the latter example, the value used by the goroutine will be the value at the time the `go` line is executed. This is usually what you want.

### Naming Stuff is Hard
Another abuse of closures I often see is create a large closure inside another function to pass into some other call that takes a function type:

```go
func MyCoolFunc() {
    package.LibraryCall(func(x, y int) error {
        // 10 to 100's of lines of code
    })
}
```

Again, this seems like a reasonable use but there's a better way to do the same thing:

```go
func functionWithDescriptiveName(x, y int) error {
    // 10 to 100's of lines of code
}

func MyCoolFunc() {
    package.LibraryCall(functionWithDescriptiveName)
}
```

If the former example included some comments about implementation, it might be ok to inline a ton of unamed business logic. In my experience, this rarely happens as writing comments is a seemingly lost art (which is a whole different blog post). My rule of thumb is that if a closure is over about five lines, it should get pulled out into it's own named function or method.

### Methods are Functions Too
Here's one I've seen that seems to me like it's really going out of it's way to add unecessary wrapping for no reason:

```go
func (x X) MyHandler() func(w http.ResponseWriter, r *http.Request) {
    return func(w http.ResponseWriter, r *http.Request) {
        // Code using x by capture
    }
}

http.HandleFunc("/foo", x.MyHandler())
```

Go allows any method to be used as a function type if the signature matches, so this is the better way of doing the same thing:

```go
func (x X) MyHandler(w http.ResponseWriter, r *http.Request) {
    // Exact same code as above
}

http.HandleFunc("/foo", x.MyHandler)
```

Not only does the latter have much less code to read, it's easier to debug because it won't include an extra stack hop through the file where `http.Handle` was called with an anoymous `func1` on the end.

### Bad Examples
While we're on the topic of HTTP handlers, pretty much [every](https://pkg.go.dev/net/http#hdr-Servers) [example](https://pkg.go.dev/github.com/gin-gonic/gin#section-readme) [on](https://github.com/kataras/iris) [the](https://echo.labstack.com/docs/quick-start) [internet](https://github.com/go-chi/chi) uses function literals for their short examples. I get it, the closure examples are very terse to allow for the shortest possible working example. And most show a better way of organizing handlers if you get past the first example. Unfortunately, many developers use the first pattern they see and you end up getting something like:

```go
func RegisterHandlerFoo(router http.ServeMux) {
    router.HandleFunc("/foo", func(w http.ResponseWriter, r *http.Request) {
        // Foo Handler Body
    })
}
```

I've even seen something this:

```go
router.HandleFunc("/foo", func(w http.ResponseWriter, r *http.Request) { FooHandler(w,r) })
```

These usually are mistakes made by developers new to go who see the examples and assume it's always best to wrap all your handlers in an anonymous function.

Do this instead:

```go
func FooHandler(w http.ResponseWriter, r *http.Request) {
    // Foo Handler Body
}

router.HandleFunc("/foo", FooHandler))
```

There's no scalable way to keep adding inline closures as your project grows. The handlers will need to be spread out across different directories and files to keep things organized. The simplest way to do that is with functions or methods.

### Setup vs. Runtime Confusion
I saved my last example as the most controversial; and maybe most opinionated. Using closures to capture dependencies is a bad pattern. I think propagation of this pattern comes from some popular community members including [this post.](https://grafana.com/blog/2024/02/09/how-i-write-http-services-in-go-after-13-years/#maker-funcs-return-the-handler)

```go
func handleSomething(logger *Logger) http.Handler {
	thing := prepareThing()
	return http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			// use thing to handle request
			logger.Info(r.Context(), "msg", "handleSomething")
		}
	)
}
```

This example looks pretty reasonable because there's just one dependency injected. My experience is that this gets far more complicated in practice. First, it mixes up the initialization code that gets run once at boot with the handler that is run on every request. Second, the dependecy list can get very long requiring capture of a large number of variables.

I joined a project that used this pattern and several complex handlers had over twenty parameters. Sometimes, the dependency was only used in the prepare stage, sometimes it was used in the handler and sometimes both. One function had about a hundred lines of "prepare" and another hundred lines of handler code. Looking through the git history, the handler had started out simple but over time had gotten more and more complicated. By the time I joined, the team was made up of relatively junior developers. They didn't know how to break up this pattern since all the handlers in the code base used closures to capture the dependencies.

I prefer to manage dependencies as a struct instead:

```go
func HandlerGroup struct {
    logger *Logger
    thing  *Thing
    // Other deps
}

// Setup code here
func NewHandlerGroup(logger *Logger /* other deps */) *HandlerGroup {
    thing := prepareThing()
    return &HandlerGroup{
        logger: logger,
        thing:  thing,
        // Other deps
    }
}

func (hg *HandlerGroup) Something(http.ResponseWriter, r *http.Request) {
    // use thing to handle request
	logger.Info(r.Context(), "msg", "Something")
}
```
While this is a bit longer, it clearly separates the setup code from the runtime code. It also has the advantage that you can add more handlers to the `HandlerGroup`. Similar handlers, often with the same dependency requirements can be gathered together under the same type. Think of RESTful CRUD handlers on the same resource that all have a depend on an object that performs the database operations.

## Where I Use Closures
While I try to minimize their use, I do find closures handy on occasion. Here are a few example patterns where closures are probably the best option.

### Short Inline Functions
Let's say I want to log an error rather than ignoring it:
```
defer func() {
    err := f.Close()
    if err != nil {
        log.Println(err)
    }
}()
```
This could be done with a named function, but it would remove little complexity given how short this closure is. If I needed to do something more complex I probably would pull it out into a named function.

### Signature Changes
```
thing := getThing()
funcINeed := func() SomeReturnValue {
    return funcIHave(thing)
}
x.SomeAPICall(funcINeed)
```
`SomeAPICall` requires an empty function that returns `SomeReturnValue` type. My `funcIHave` returns the right value, but requires I pass in `thing`. Using a closure to capture `thing` so I can match types is very useful. I try to keep the body of the closure to a single line so it's as clear as possible what's being captured.

## Takeaway
In most cases, a named function or method can replace a closure. Named functions allow for better documentation and less nesting which makes your code more readable and easier to maintain. I find thinking about the name also forces me to create a better contract for the block of code. If you find you're using a closure to capture a large number of variables, it's probably time for a refactor. Using a struct to hold the same items and then calling a method to perform the same action makes the code more explicit that it depends on those items.

Closures in Go provide powerful functionality by implicitly capturing variables from the surrounding scope. However, this power comes with potential pitfalls, especially when working with concurrency or when closures grow complex and capture numerous outer variables. By keeping closures concise and using them only when alternatives would be less elegant, you'll enhance your code's readability and maintainability.
