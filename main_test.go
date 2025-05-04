package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestMain(t *testing.T) {
	main()
}

func TestOnceMore(t *testing.T) {
	assert.Equal(t, 1, 1)
}
func TestSoMore(t *testing.T) {
	assert.Equal(t, 1, 1)
}
func TestMore(t *testing.T) {
	assert.Equal(t, 1, 1)
}
func TestAgain(t *testing.T) {
	assert.Equal(t, 1, 1)
}
