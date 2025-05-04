package main

import (
	"fmt"
	"strings"
)

type Foo struct {
	ID   int
	Name string
}

func main() {
	fmt.Println("Hello World!")
	p := &Foo{
		ID:   1,
		Name: "foo1",
	}
	fmt.Printf("%+v\n", p)
	fmt.Println("hello")
	p1 := &Foo{
		ID:   2,
		Name: "foo2",
	}
	split := strings.Split(p1.Name, "")
	fmt.Println(split)

	p2 := &Foo{
		ID:   3,
		Name: "foo3",
	}

	fmt.Printf("%+v\n", p2)
}
