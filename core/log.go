package core

import (
	"fmt"
	"runtime"
	"strings"
)

func MantleDebug(s string) {
	Debug("%s", s)
}

func Debug(format string, a ...interface{}) {
	if LogLevel >= LogLevelDebug {
		out(fmt.Sprintf("%s", fmt.Sprintf(format, a...)))
	}
}

func MantleInfo(s string) {
	Info("%s", s)
}

func Info(format string, a ...interface{}) {
	if LogLevel >= LogLevelInfo {
		out(fmt.Sprintf("%s", fmt.Sprintf(format, a...)))
	}
}

func MantleWarn(s string) {
	Warn("%s", s)
}

func Warn(format string, a ...interface{}) {
	if LogLevel >= LogLevelWarn {
		out(fmt.Sprintf("WARN: %s", fmt.Sprintf(format, a...)))
	}
}

func MantleError(s string) {
	Error("%s", s)
}

func Error(format string, a ...interface{}) {
	if LogLevel >= LogLevelErr {
		out(fmt.Sprintf("ERROR: %s", fmt.Sprintf(format, a...)))
	}
}

func MantleApplication(s string) {
	Application("%s", s)
}

func Application(format string, a ...interface{}) {
	if LogLevel >= LogLevelApp {
		// out(fmt.Sprintf(format, a...))

		// TODO: Use out here, please
		fmt.Println(fmt.Sprintf(format, a...))
	}
}

func out(mess string) {
	// Injectible writer-- useful for JS
	// if writer != nil {
	// 	writer.Write(fmt.Sprintf("[%s] %s", trace(), mess))
	// }

	if ShouldLogLineNumber {
		fmt.Println(fmt.Sprintf("[%s] %s", trace(), mess))
	} else {
		fmt.Println(fmt.Sprintf("%s", mess))
	}
}

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
