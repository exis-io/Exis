package core

import (
	"fmt"
	"runtime"
	"strings"
)

func Debug(format string, a ...interface{}) {
	if LogLevel >= LogLevelDebug {
		out(fmt.Sprintf("core-debug: %s", fmt.Sprintf(format, a...)))
	}
}

func Info(format string, a ...interface{}) {
	if LogLevel >= LogLevelInfo {
		out(fmt.Sprintf("core-info: %s", fmt.Sprintf(format, a...)))
	}
}

func Warn(format string, a ...interface{}) {
	if LogLevel >= LogLevelWarn {
		out(fmt.Sprintf("core-warn: %s", fmt.Sprintf(format, a...)))
	}
}

func Error(format string, a ...interface{}) {
	if LogLevel >= LogLevelErr {
		out(fmt.Sprintf("core-error: %s", fmt.Sprintf(format, a...)))
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
