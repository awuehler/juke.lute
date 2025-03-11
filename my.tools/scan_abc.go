package main

// ...
import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

// InputPrompt receives a string value using the label
func InputPrompt(label string) string {
	var s string
	r := bufio.NewReader(os.Stdin)
	for {
		fmt.Fprint(os.Stderr, label+" ")
		s, _ = r.ReadString('\n')
		if s != "" {
			break
		}
	}
	return strings.TrimSpace(s)
}

// ...
func main() {
	message := InputPrompt("Enter test message:")
	fmt.Printf("User input: %s!\n", message)
}
