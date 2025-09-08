package calculator

import (
	"errors"
	"fmt"
	"strconv"
	"strings"
	"unicode"
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

		// parsing next term and adding
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
	// parsing left factor
	left, err := parseFactor(reader)
	if err != nil {
		return 0, err
	}

	for {
		// reading next symbol
		op, _, err := reader.ReadRune()
		if err != nil {
			break // Конец выражения
		}

		if op != '*' && op != '/' {
			reader.UnreadRune()
			break
		}

		// parsing next factor and multiplicating
		right, err := parseFactor(reader)
		if err != nil {
			return 0, err
		}

		switch op {
		case '*':
			left *= right
		case '/':
			if right == 0 {
				return 0, errors.New("zero division")
			}
			left /= right
		}
	}

	return left, nil
}

// processes numbers and скобки
func parseFactor(reader *strings.Reader) (float64, error) {
	// reading first symbol
	ch, _, err := reader.ReadRune()
	if err != nil {
		return 0, errors.New("expecting number or скобка")
	}

	// parsing whats in скобки
	if ch == '(' {
		result, err := parseExpression(reader)
		if err != nil {
			return 0, err
		}

		// expecting closing скобка
		ch, _, err := reader.ReadRune()
		if err != nil || ch != ')' {
			return 0, errors.New("expecting closing скобка")
		}

		return result, nil
	}

	// reading number
	if unicode.IsDigit(ch) || ch == '.' || ch == '-' {
		reader.UnreadRune()
		return parseNumber(reader)
	}

	return 0, fmt.Errorf("unexpected symbol: %c", ch)
}

// reads number from reader
func parseNumber(reader *strings.Reader) (float64, error) {
	var numStr strings.Builder

	// if number is negative
	ch, _, err := reader.ReadRune()
	if err != nil {
		return 0, errors.New("ожидается число")
	}

	if ch == '-' {
		numStr.WriteRune(ch)

		// reading next symbol
		ch, _, err = reader.ReadRune()
		if err != nil {
			return 0, errors.New("ожидается число после минуса")
		}
	}

	// the number
	for {
		if unicode.IsDigit(ch) || ch == '.' {
			numStr.WriteRune(ch)
		} else {
			reader.UnreadRune()
			break
		}

		// next symbol
		ch, _, err = reader.ReadRune()
		if err != nil {
			break
		}
	}

	// string to float
	num, err := strconv.ParseFloat(numStr.String(), 64)
	if err != nil {
		return 0, fmt.Errorf("неверное число: %s", numStr.String())
	}

	return num, nil
}
