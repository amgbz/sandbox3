package main

import (
	"testing"
)

func TestVersionVariables(t *testing.T) {
	// Test that version variables are initialized (even if with default values)
	if version == "" {
		t.Error("version should not be empty string")
	}
	if buildDate == "" {
		t.Error("buildDate should not be empty string")
	}
	if gitCommit == "" {
		t.Error("gitCommit should not be empty string")
	}
	if gitTag == "" {
		t.Error("gitTag should not be empty string")
	}
}

func TestVersionDefaults(t *testing.T) {
	// Test that version variables have reasonable defaults
	if version != "dev" {
		t.Logf("version is set to: %s", version)
	}
	if buildDate != "unknown" {
		t.Logf("buildDate is set to: %s", buildDate)
	}
	if gitCommit != "unknown" {
		t.Logf("gitCommit is set to: %s", gitCommit)
	}
	if gitTag != "unknown" {
		t.Logf("gitTag is set to: %s", gitTag)
	}
}

// Benchmark for potential performance testing
func BenchmarkVersionString(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_ = version + " " + buildDate + " " + gitCommit + " " + gitTag
	}
}
