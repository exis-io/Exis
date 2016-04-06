package core

// High level, ORM-like bindings. Like Domain, the models here mirror crust objects. Unlike
// the crust, Models do not store their mirror's data-- this interface is much more functional.
// All functions return the model's "contents"

// Note that this implementation assumes that there's a global, single connection. This might be ok.
// since this is such a difference you'll still need to pass the connection to the model
type model struct {
	storage Domain // the domain of the storage appliance responsible for our data
}

type Model interface {
	Find(string, string) (string, error)
	Create(string, string) (string, error)
	Save(string, string) (string, error)
	Count(string) (string, error)

	Query(string, string, interface{}) ([]interface{}, error)
}

// Set a session and return a new model interface. The session must already be joined
func SetSession(appDomain Domain) Model {
	Debug("Initialized models")
	// Note the hardcoded storage domain endpoint. Temporary
	s := "Storage"

	return &model{storage: appDomain.Subdomain(s)}
}

func (m *model) Query(endpoint string, collection string, query interface{}) ([]interface{}, error) {
	a := []interface{}{collection}

	// if query != nil {
	// 	a = append(a, query)
	// }

	r, e := m.storage.Call(endpoint, a, nil)
	Info("Model operation: %s, Name: %s, Query: %s: Result: %s Error: %s", endpoint, collection, query, r, e.Error())
	return r, e
}

// Executes the query against the collection
func (m *model) query(endpoint string, collection string, query string) (string, error) {
	r, e := m.storage.Call(endpoint, []interface{}{collection, query}, nil)
	Info("Model operation: %s, Name: %s, Query: %s: Result: %s Error: %s", endpoint, collection, query, r, e.Error())
	return "", e
}

// Model query functions. Each mantle should copy this interface, crusts should emulate it
// Arguments: the name of the model, contents of the query based on the call
// All the methods return (string, error) to map easily to the query method

func (m *model) Find(collection string, query string) (string, error) {
	return m.query("collection/find", collection, query)
}

func (m *model) Create(collection string, query string) (string, error) {
	return m.query("collection/insert_one", collection, query)
}

func (m *model) Save(collection string, query string) (string, error) {
	// Check the count of the incoming models and call update_many?
	return m.query("update_one", collection, query)
}

func (m *model) Count(collection string) (string, error) {
	return m.query("count", collection, "")
}
