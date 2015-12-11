package core

import (
	"fmt"
	"runtime"
	"strings"
)

const (
	LogLevelApp   int = 0
	LogLevelErr   int = 1
	LogLevelWarn  int = 2
	LogLevelInfo  int = 3
	LogLevelDebug int = 4
)

var LogLevel int = 1

func Debug(format string, a ...interface{}) {
	if LogLevel >= LogLevelDebug {
		out(fmt.Sprintf("%s", fmt.Sprintf(format, a...)))
	}
}

func Info(format string, a ...interface{}) {
	if LogLevel >= LogLevelInfo {
		out(fmt.Sprintf("%s", fmt.Sprintf(format, a...)))
	}
}

func Warn(format string, a ...interface{}) {
	if LogLevel >= LogLevelWarn {
		out(fmt.Sprintf("%s", fmt.Sprintf(format, a...)))
	}
}

func Error(format string, a ...interface{}) {
	if LogLevel >= LogLevelErr {
		out(fmt.Sprintf("%s", fmt.Sprintf(format, a...)))
	}
}

func Application(format string, a ...interface{}) {
	if LogLevel >= LogLevelApp {
		out(fmt.Sprintf("%s", fmt.Sprintf(format, a...)))
	}
}

func out(mess string) {
	// if writer != nil {
	// 	writer.Write(fmt.Sprintf("[%s] %s", trace(), mess))
	// }

	fmt.Println(fmt.Sprintf("[%s] %s", trace(), mess))
}

// This might not make any sense for non-go languages...
func trace() string {
	pc := make([]uintptr, 10) // at least 1 entry needed
	runtime.Callers(4, pc)
	f := runtime.FuncForPC(pc[0])
	file, line := f.FileLine(pc[0])

	parts := strings.Split(file, "/")

	if len(parts) > 3 {
		last := parts[len(parts)-2:]
		file = strings.Join(last, ".")
	}

	return fmt.Sprintf("%s:%d", strings.TrimSuffix(file, ".go"), line)
}
