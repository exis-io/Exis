package goRiffle

// Settings and utilities within Riffle

import "github.com/exis-io/core"

// Fabric
func SetFabricDev() {
	core.Fabric = core.FabricDev
	core.Registrar = core.RegistrarDev
}

func SetFabricProduction() {
	core.Fabric = core.FabricProduction
	core.Registrar = core.RegistrarProduction
}

func SetFabricLocal() {
	core.Fabric = core.FabricLocal
	core.Registrar = core.RegistrarLocal
}

func SetFabricSandbox()       { core.Fabric = core.FabricSandbox }
func SetFabric(url string)    { core.Fabric = url }
func SetRegistrar(url string) { core.Registrar = url }

// Log Levels
func SetLogLevelOff()   { core.LogLevel = core.LogLevelOff }
func SetLogLevelApp()   { core.LogLevel = core.LogLevelApp }
func SetLogLevelErr()   { core.LogLevel = core.LogLevelErr }
func SetLogLevelWarn()  { core.LogLevel = core.LogLevelWarn }
func SetLogLevelInfo()  { core.LogLevel = core.LogLevelInfo }
func SetLogLevelDebug() { core.LogLevel = core.LogLevelDebug }

// Logging
func Application(format string, args ...interface{}) { core.Application(format, args...) }
func Debug(format string, args ...interface{})       { core.Debug(format, args...) }
func Info(format string, args ...interface{})        { core.Info(format, args...) }
func Warn(format string, args ...interface{})        { core.Warn(format, args...) }
func Error(format string, args ...interface{})       { core.Error(format, args...) }
