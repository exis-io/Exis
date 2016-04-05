package core

// High level, ORM-like bindings. Like Domain, the models here mirror crust objects. Unlike
// the crust, Models do not store their mirror's data-- this interface is much more functional.
// All functions return strings directly

// Note that this implementation assumes that there's a global, single connection. This might be ok.
// since this is such a difference you'll still need to pass the connection to the model 
// type model struct {
//     App
//     storageDomain string  // who do we ask for information
// }

// type Model interface {
//     Query(string, string)
// }

// // Set a session and return a new model interface
// func SetSession(a App) Model {
//     return &model{a}
// }

// // Executes the query against the collection
// func (m Model) Query(collection string, query string) {

// }

// // Find all models that match the given query. Return all if no query passed
// func (m Model) Find(collection string, query string) (string, err) {
//     return "", nil
// }

// func (m Model) Create(collection string, query string) (string, err) {
//     return "", nil
// }

// func (m Model) Save(collection string, query string) (string, err) {
//     return "", nil
// }

