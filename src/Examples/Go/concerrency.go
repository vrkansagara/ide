package main

// https://pkg.go.dev/std ( fmt is standard library.)
// https://pkg.go.dev/fmt
// https://making.pusher.com/my-5-favourite-features-of-go-and-how-to-use-them/
// https://gobyexample.com/hello-world
import (
        "fmt"
        "time"
       )

func doSomething(str string) {
    for i := 1; i <= 3; i++ {
        fmt.Printf("%s: %d \n", str, i)
    }
}

func main() {
    // calling this function the normal way
    doSomething("Hello")

        // Running it inside a go routine
        go doSomething("World")

        go func() {
            fmt.Print("Go routines are awesome \n")
        }()

    time.Sleep(time.Second)
        fmt.Println("done")
}

