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
	Find(string, map[string]interface{}) ([]interface{}, error)
	Create(string, map[string]interface{}) ([]interface{}, error)
	Save(string, map[string]interface{}) ([]interface{}, error)
	Count(string) ([]interface{}, error)
}

// Set a session and return a new model interface. The session must already be joined
func SetSession(appDomain Domain) Model {
	// Note the hardcoded storage domain endpoint. Temporary!
	s := "Storage"
	return &model{storage: appDomain.Subdomain(s)}
}

// Executes the query against the collection
func (m *model) query(endpoint string, collection string, query map[string]interface{}) ([]interface{}, error) {
	r, e := m.storage.Call(endpoint, []interface{}{collection, query}, nil)
	Info("Model operation: %s, Name: %s, Query: %s: Result: %s Error: %v", endpoint, collection, query, r, e)
	return r, e
}

// Model query functions. Each mantle should copy this interface, crusts should emulate it
// Arguments: the name of the model, contents of the query based on the call
// All the methods return (string, error) to map easily to the query method

func (m *model) Find(collection string, query map[string]interface{}) ([]interface{}, error) {
	return m.query("collection/find", collection, query)
}

func (m *model) All(collection string) ([]interface{}, error) {
	return m.Find(collection, nil)
}

func (m *model) Create(collection string, query map[string]interface{}) ([]interface{}, error) {
	return m.query("collection/insert_one", collection, query)
}

func (m *model) Save(collection string, query map[string]interface{}) ([]interface{}, error) {
	// Check the count of the incoming models and call update_many?
	return m.query("collection/update_one", collection, query)
}

func (m *model) Count(collection string) ([]interface{}, error) {
	return m.query("collection/count", collection, nil)
}
