package auth

import (
	"net/http"
	"strings"
	"testing"
)

func TestGetAPIKey(t *testing.T) {
	testCases := []struct {
		name           string
		headers        http.Header
		expectedKey    string
		expectedError  error
		errorSubstring string
	}{
		{
			name:          "Valid API Key",
			headers:       http.Header{"Authorization": []string{"ApiKey test-api-key-12345"}},
			expectedKey:   "test-api-key-12345",
			expectedError: nil,
		},
		{
			name:           "No Authorization Header",
			headers:        http.Header{},
			expectedKey:    "",
			expectedError:  ErrNoAuthHeaderIncluded,
			errorSubstring: "no authorization header",
		},
		{
			name:           "Malformed Header - No ApiKey Prefix",
			headers:        http.Header{"Authorization": []string{"Bearer test-api-key-12345"}},
			expectedKey:    "",
			errorSubstring: "malformed authorization header",
		},
		{
			name:           "Malformed Header - No Space",
			headers:        http.Header{"Authorization": []string{"ApiKeytest-api-key-12345"}},
			expectedKey:    "",
			errorSubstring: "malformed authorization header",
		},
		{
			name:           "Malformed Header - Empty",
			headers:        http.Header{"Authorization": []string{""}},
			expectedKey:    "",
			errorSubstring: "malformed authorization header",
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			key, err := GetAPIKey(tc.headers)

			// Check the returned key
			if key != tc.expectedKey {
				t.Errorf("Expected API key %q, but got %q", tc.expectedKey, key)
			}

			// Check for specific error
			if tc.expectedError != nil && err != tc.expectedError {
				t.Errorf("Expected error %v, but got %v", tc.expectedError, err)
			}

			// Check for error substring when we don't have a specific error to compare
			if tc.errorSubstring != "" && (err == nil || !strings.Contains(err.Error(), tc.errorSubstring)) {
				if err == nil {
					t.Errorf("Expected error containing %q, but got nil", tc.errorSubstring)
				} else {
					t.Errorf("Expected error containing %q, but got %q", tc.errorSubstring, err.Error())
				}
			}
		})
	}
}
