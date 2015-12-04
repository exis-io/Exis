package goriffle

// import (
// 	"os"

// 	"github.com/op/go-logging"
// )

// // Check out their github page for more info on the coloring
// var format = logging.MustStringFormatter(
// 	"%{color}[%{time:2006-01-02 15:04:05.000} %{longfunc}] %{message}%{color:reset}",
// 	// "[%{color}%{time:15:04:05.000} %{longfunc}]  %{message}",
// )

// func Log() {
// 	// For demo purposes, create two backend for os.Stderr.
// 	// backend1 := logging.NewLogBackend(os.Stderr, "", 0)
// 	// formatter := logging.NewBackendFormatter(backend1, format)
// 	// backend1Leveled := logging.AddModuleLevel(backend1)

// 	// if os.Getenv("DEBUG") != "" {
// 	// 	backend1Leveled.SetLevel(logging.DEBUG, "")
// 	// } else {
// 	// 	backend1Leveled.SetLevel(logging.CRITICAL, "")
// 	// }

// 	// logging.SetBackend(backend1Leveled, formatter)

// 	// out.Debug("debug %s", Password("secret"))
// 	// out.Info("info")
// 	// out.Notice("notice")
// 	// out.Warning("warning")
// 	// out.Error("err")
// 	// out.Critical("crit")
// }

// func logErr(err error) error {
// 	if err == nil {
// 		return nil
// 	}

// 	return err
// }

// // New Logging implementation
// var out = logging.MustGetLogger("example")

// // Password is just an example type implementing the Redactor interface. Any
// // time this is logged, the Redacted() function will be called.
// type Password string
