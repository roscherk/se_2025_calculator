package loggersrc

import (
	"fmt"

	_ "github.com/roscherk/se_2025_calculator/docs"
)

type ILogger interface {
	Log(string)
}

type BaseLogger struct {
}

func (curLogger BaseLogger) Log(curStr string) {
	fmt.Println(curStr)
}
