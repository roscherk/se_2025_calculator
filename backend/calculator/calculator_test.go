package calculator

import (
	"testing"
)

func TestEvaluate(t *testing.T) {
	tests := []struct {
		name     string
		expr     string
		expected float64
		hasError bool
	}{
		{
			name:     "empty", // i think its good to expect 0 without exception
			expr:     "",
			expected: 0,
			hasError: false,
		},
		{
			name:     "empty with spaces",
			expr:     "     ",
			expected: 0,
			hasError: false,
		},
		{
			name:     "one number",
			expr:     "-2.6",
			expected: -2.6,
			hasError: false,
		},
		{
			name:     "one number",
			expr:     ".5",
			expected: 0.5,
			hasError: false,
		},
		{
			name:     "simple addition",
			expr:     "2 + 3",
			expected: 5,
			hasError: false,
		},
		{
			name:     "simple subtraction",
			expr:     "2 - 7",
			expected: -5,
			hasError: false,
		},
		{
			name:     "simple multiplication",
			expr:     "5 * 3",
			expected: 15,
			hasError: false,
		},
		{
			name:     "simple division",
			expr:     "4 / 2",
			expected: 2,
			hasError: false,
		},
		{
			name:     "division by zero",
			expr:     "10 / 0",
			expected: 0,
			hasError: true, // expecting error
		},
		{
			name:     "more complicated expression",
			expr:     "1 / (4 + 2 * 3) + 17 * (5 - 9)",
			expected: -67.9,
			hasError: false,
		},
		{
			name:     "1",
			expr:     "2 * (-3)",
			expected: -6,
			hasError: false,
		},
		{
			name:     "2",
			expr:     "2 - (-3)",
			expected: 5,
			hasError: false,
		},
		{
			name:     "3",
			expr:     "-3 + 5",
			expected: 2,
			hasError: false,
		},
		// more tests
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			res, err := Evaluate(tt.expr)

			if tt.hasError {
				if err == nil {
					t.Errorf("Expected error for expression %s, but got nil and result %f", tt.expr, res)
				}
				return
			}

			if err != nil {
				t.Errorf("Unexpected error for expression %s: %v", tt.expr, err)
				return
			}

			if res != tt.expected {
				t.Errorf("Evaluate(%s) = %f, expected %f", tt.expr, res, tt.expected)
			}
		})
	}
}
