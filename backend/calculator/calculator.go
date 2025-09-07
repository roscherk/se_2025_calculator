package main

import (
	"github.com/expr-lang/expr"
)

// Getting expression from frontend -> evaluating
// its value or giving exception if there's error
func Evaluate(expression string) (float64, error) {
	program, err := expr.Compile(expression, expr.AsFloat64())
	if err != nil {
		return 0, err
	}

	output, err := expr.Run(program, nil)
	if err != nil {
		return 0, err
	}

	result, ok := output.(float64)
	if !ok {
		return 0, err
	}

	return result, nil
}

// usage:
/*
 * res, err := calculator.Evaluate("1/4 + 2 * (3 - 14)")
 *
 * if err != nil {
 *   // couldnt evaluate
 * }
 *
 * // else result in 'res'
 *
 */
