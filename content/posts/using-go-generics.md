+++
date = '2021-08-17T12:00:00-08:00'
lastmod = '2024-12-05T16:22:00-08:00'
title = 'Using Go Generics'
featured_image='/img/natalia-y-Oxl_KBNqxGA-unsplash.jpg'
summary = 'A real-world example of adding Go generics to a package.'
+++
I was pairing with another engineer the other day and we needed to download some largish mp4 files and process the headers. The service could possibly get multiple requests at once, so we wanted to deduplicate the expensive requests and return the same value to all the concurrent requesters. I’ve often written similar code and with Go’s excellent concurrency primitives it’s usually a pretty simple task. After about an hour we had the code working and it seemed pretty straight-forward. The next day when I was reviewing the PR, I noticed a possible deadlock. I guess this wasn’t as simple as I had first thought. After fixing the deadlock, I decided to extract the core of the code into a reusable library so the next person wouldn’t make the same mistake.

I think you might be guessing where this is going. Once the package was extracted to be reusable, the concrete types we originally used for our specific use case all became the empty interface (`interface{}`).

I had been casually following the development of generics in Go. I read several blog posts and articles, but I hadn’t dug into the proposals or written any code. I knew the latest proposal was approved and should be landing in a future go release (probably 1.18). This little library ([deduper](https://github.com/smw1218/deduper)) seemed like a great opportunity to try out generics in Go.

## Genericizing

Once initialized, using a deduper is simple; just call the Get method:

```go
dd := deduper.NewDeduper(...)
value, err := dd.Get(request)
```

In the pre-generics version you’d then have to type assert value to your concrete type. Using Go generics, I’ve replaced that with type T so

```go
func (dd *Deduper) Get(m Request) (interface{}, error)
```

becomes

```go
func (dd *Deduper[T]) Get(m Request) (T, error)
```

The Request passed into the Get call is an interface:

```go
type Request interface {
    Payload() interface{}
}
```

The Payload function returns a value that is used by the worker function to make the request. In our code it was a struct representing a database record, but it could be an http.Request or anything else. That gives us our second generic type making Request into:

```go
type Request[U any] interface {
    Payload() U
}
```

and Get into:

```go
func (dd *Deduper[T, U]) Get(m Request[U]) (T, error)
```

Now that we have our generic return type T and Payload type U we can define the worker function as:

```go
type WorkerFunc[T any, U any] func(req Request[U]) (T, error)
```

I decided to pass the entire Request but, I could have also just as easily passed in the only the Payload:

```go
type WorkerFunc[T any, U any] func(payload U) (T, error)
```

That covers the entire public API for the library. The rest of the work was propagating these generic types throughout the internals of the code. This was mostly copy/paste to add the generic types and type parameters where needed. The compiler is your friend on this step as go compile will helpfully point out what you’re missing.

## Using the Generic Library

In this short example, both `T` and `U` are type `string`:

```go
workerFunc := func(req deduper.Request[string]) (string, error) { 
    ...
}
dd := deduper.NewDeduper(3, workerFunc) // 3 workers
val, err := dd.Get(myRequest) // val is type string
...
```

I didn’t need to specify types for either `T` or `U` when I called `NewDeduper` because the types could be inferred from `workerFunc`. The variable `val` is a concrete `string` and doesn’t need a type assertion. Neither does the `string` returned by calling `req.Payload()`. This is great, now I have compile time type safety! Bonus is that with the type inference, the calling code looks almost the same. I think this will apply to many use cases when generics are added, the calling code will look like regular Go with a few less type assertions and compile time type checking.

## Comparing Using Generics vs. Not

After I got everything working on with generics, I decided to check how different the code is without them. It was pretty trivial to delete all the type parameter lists and switch the `T` and `U` back to `interface{}`. I also back ported my example to go without generics. If we compare a few pieces of code we can see the difference.

Go Generics

```go
val, _ := dd.Get(helloRequest("world!"))
fmt.Println(val)
```

Go No Generics

```go
val, _ := dd.Get(helloRequest("world!"))
// not strictly necessary for this trivial example to do the 
// type assertion
if valStr, ok := val.(string); ok {
    fmt.Println(valStr)
}
```

I needed to add a type assertion and possibly handle a runtime error case if the type isn’t what I expect. The difference is just a few line of extra code.

Let’s look at the Payload usage as well.

Go Generics

```go
return fmt.Sprintf("Hello, %v", req.Payload()), nil
```

Go No Generics

```go
// not strictly necessary for this trivial example to do the 
// type assertion
if payload, ok := req.Payload().(string); ok {
    return fmt.Sprintf(“Hello, %v”, payload), nil
}
return nil, fmt.Errorf(“Value not expected string %T”, req.Payload())
```

This includes error handling in case the type assertion fails, but the non-generic code is still only a few extra lines of code.

## Comparing Writing Generics vs. Not

Looking at the library code, we find that it is significantly more complicated with all the type parameter lists. The internals of the deduper library has multiple internal data structures like channels that use the generic types. Type inference didn’t help much here and I needed to add the type parameter lists to almost every function. Here are a few internal examples:

```go
func (dd *Deduper[T, U]) queueRequestChan(request *requestWrapper[T, U], 
    savedRequest map[interface{}][]*requestWrapper[T, U])
func (dd *Deduper[T, U]) processResult(rw *resultWrapper[T, U], 
    savedRequest map[interface{}][]*requestWrapper[T, U])
```

Unlike Java, where the generic types are defined on the class and used consistently, every type or function in Go requires redefinition of the parameter types. This means you can use different placeholders in every instance. Like using different method receiver variables, the solution is “don’t do that.” I accidentally reversed my types at one point, but when I tried to use the wrong type the compiler caught it. I was very impressed with the clarity of the compiler error messages. The most common one is an alert when a required parameter list is missing. The messages were so clear and accurate I’m assuming this will autocomplete in the future.

## Conclusions

I found it easy and intuitive to use Go’s new generics. I should caveat this by saying that I am familiar with generics in Java and, once I figured out the syntax, that knowledge was easily transferred. I barely skimmed the first part of the proposal before writing the whole library. I didn’t need any fancy constraints for this project.

I’ve been on the fence watching the community’s battle over adding generics to Go. I can see both side of the argument; generics can add complexity and hurt readability vs. the ability to write more reusable code. I’ve read several other articles that include very basic usage, usually targeting list manipulation utilities where generics provide an obvious benefit. I needed to try them myself to form my own opinion, so taking a real piece of code and porting it would be a good way to test the waters.

Working with Go’s generics was simple and straight-forward with my past experience using generics in Java. It took minimal reading just to get the syntax, then the helpful compiler errors helped with the rest. Day to day editing is rough because of lack of tooling, but that should get fixed as generics approach release. I was impressed by how few issues I ran into using a pre-release feature. I was expecting to spend large amounts of time trying to figure out what I had missed based on vague compilation failures, but at every point it was obvious what I needed to fix.

Unfortunately, I think the type parameter lists significantly reduce readability of the library code. Both examples are in the repo so you can judge for yourself. When I compare the two, the benefit of saving a few lines of type checking to the cost in readability of the library code, generics don’t seem worth it to me in this use case. It also takes a significant amount of time to propagate the generic types throughout the code. I’m also worried that many developers will lose the proper design of their code in generic soup. It’s much harder to see design flaws and even bugs when the types are generic rather than concrete. I got confused a few times in the this code and I was already starting from a working design. This was an issue I saw often with generics in Java.

I should note that we’re not actually using this library in production. The path we took was summarized by:

> A little copying is better than a little dependency.
> — Rob Pike

Our code copies the functionality and replaces the `interface{}` with the concrete types that we needed. I’m not sure if Rob would agree that a 100+ lines of copying qualifies as “A little,” but it avoids the type checking issue entirely. It also removes a few levels of abstraction that was needed to make the code reusable. This makes the footprint even smaller and easier to manage.

I know these same points have been well documented throughout the entire generics debate, but I’m glad that I took the time to experiment myself and I encourage others to do so as well. I like Go’s clean and non-intrusive approach as well as the clear benefits we’ll get from generic libraries for container and math operations. My opinion about using generics will likely change over time once generics are in broader use (especially in the standard library). I hope that Go keeps its clean and simple look and feel that makes it such a joy to program.