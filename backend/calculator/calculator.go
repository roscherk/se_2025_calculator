package calculator

import (
	"errors"
	"strings"
)

// Getting expression from frontend -> evaluating
// its value or giving exception if there's error
func Evaluate(expression string) (float64, error) {
	expr := strings.ReplaceAll(expression, " ", "")

	if expr == "" {
		return 0, nil
	}

	reader := strings.NewReader(expr)

	result, err := parseExpression(reader)
	if err != nil {
		return 0, err
	}

	if reader.Len() > 0 {
		return 0, errors.New("unexpected symbols in expression")
	}

	return result, nil
}

// processing adding (or subtracting)
func parseExpression(reader *strings.Reader) (float64, error) {
	// parsing left term
	left, err := parseTerm(reader)
	if err != nil {
		return 0, err
	}

	for {
		// reading next symbol
		op, _, err := reader.ReadRune()
		if err != nil {
			break
		}

		if op != '+' && op != '-' {
			reader.UnreadRune()
			break
		}

		// parsing right term and adding
		right, err := parseTerm(reader)
		if err != nil {
			return 0, err
		}

		switch op {
		case '+':
			left += right
		case '-':
			left -= right
		}
	}

	return left, nil
}

// processing multiplication (or division)
func parseTerm(reader *strings.Reader) (float64, error) {
	// TODO

	return 0, nil
}

// processes numbers and скобки
func parseFactor(reader *strings.Reader) (float64, error) {
	// TODO

	return 0, nil
}

// reads number from reader
func parseNumber(reader *strings.Reader) (float64, error) {
	// TODO

	return 0, nil
}
