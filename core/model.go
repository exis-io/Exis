package core

import "fmt"


// High level, ORM-like bindings. Like Domain, the models here mirror crust objects. Unlike
// the crust, Models do not store their mirror's data-- this interface is much more functional.
// All functions return the model's "contents"

// Note that this implementation assumes that there's a global, single connection. This might be ok.
// since this is such a difference you'll still need to pass the connection to the model
type modelManager struct {
	storage Domain // the domain of the storage appliance responsible for our data
}

// Model Manager. Responsible for all model objects on the current connection
type ModelManager interface {
	Count(string) (uint, error)

	Find(string, map[string]interface{}) ([]map[string]interface{}, error)
	All(string) ([]map[string]interface{}, error)

	Create(string, map[string]interface{}) error
	CreateMany(string, []map[string]interface{}) error

	Save(string, map[string]interface{}) error
	SaveMany(string, []map[string]interface{}) error

	Destroy(string, string) error
	DestroyMany(string, []string) error
}

// Initialize the model manager with an opened connection and the Storage appliance's
// endpoint relative to the app. Checks to make sure a storage is actually attached.
// Fails if not connected to the fabric or the storage appliance doesn't actually exist
func (a *app) InitModels() (ModelManager, error) {
	// NOTE: storage appliance endpoint should by dynamic
	storageName := "Storage"

	if a.appDomain == "" {
		return nil, fmt.Errorf("Model initialization error: AppDomain doesn't have a domain set!")
	}

	return &modelManager{storage: a.NewDomain(a.appDomain+"."+storageName, 0, 0)}, nil
}

// Executes the query against the collection. Returns an error if the domain is not still connected
func (m *modelManager) query(endpoint string, collection string, query interface{}, filter interface{}) (interface{}, error) {
	if m.storage.GetApp().GetState() != Ready {
		return nil, fmt.Errorf("No open connections found. You must be connected to access model persistence.")
	}

	args := []interface{}{collection, query}

	if filter != nil {
		args = []interface{}{collection, filter, query}
	}

	if r, e := m.storage.Call(endpoint, args, nil); e != nil {
		return nil, e
	} else if len(r) != 1 {
		return nil, fmt.Errorf("Model query failed. Received unexpected result: %v", r)
	} else {
		fmt.Printf(" %s/%s \n\tfilter: %s\n\tquery: %s\n\tresult: %v\n", collection, endpoint, filter, query, r)
		return r[0], nil
	}
}

// Model query functions. Crusts should emulate this interface
// Arguments: the name of the model, contents of the query based on the call
// All functions share signatures for easier mantle access

func (m *modelManager) Find(collection string, query map[string]interface{}) ([]map[string]interface{}, error) {
	if r, err := m.query("collection/find", collection, query, nil); err != nil {
		return nil, err
	} else {
		if f, ok := r.([]interface{}); !ok {
			return nil, fmt.Errorf("Model find failed for %s. Could not parse %s", collection, r)
		} else {
			var ret []map[string]interface{}

			for _, v := range f {
				if j := v.(map[string]interface{}); !ok {
					return nil, fmt.Errorf("Model find failed for %s. Expected dictionary, got %v", collection, v)
				} else {
					ret = append(ret, j)
				}
			}

			return ret, nil
		}
	}
}

func (m *modelManager) All(collection string) ([]map[string]interface{}, error) {
	return m.Find(collection, nil)
}

func (m *modelManager) Create(collection string, query map[string]interface{}) error {
	_, err := m.query("collection/insert_one", collection, query, nil)
	return err
}

func (m *modelManager) CreateMany(collection string, query []map[string]interface{}) error {
	_, err := m.query("collection/insert_many", collection, query, nil)
	return err
}

func (m *modelManager) Destroy(collection string, id string) error {
	_, err := m.query("collection/delete_one", collection, map[string]interface{}{"_xsid": id}, nil)
	return err
}

func (m *modelManager) DestroyMany(collection string, id []string) error {
	filter := map[string]interface{}{"_xsid": map[string]interface{}{"$in": id}}
	_, err := m.query("collection/delete_many", collection, filter, nil)
	return err
}

func (m *modelManager) Save(collection string, query map[string]interface{}) error {
	if filter, err := createIdFilter([]map[string]interface{}{query}); err != nil {
		return err
	} else {
        fmt.Printf("Query: \n\t%v\n", query)
        fmt.Printf("Filter: \n\t%v\n", filter)

        e := fmt.Errorf("Couldn't find the model to update given %v", query)

		if ret, err := m.query("collection/replace_one", collection, query, filter); err != nil {
            return err
        } else if m, ok := ret.(map[string]interface{}); !ok {
            return e
        } else if updated, ok := m["matched_count"]; !ok {
            return e
        } else if cast, ok := updated.(float64); !ok {
            return e
        } else if cast != 1 {
            return e
        }

		return nil
	}
}

func (m *modelManager) SaveMany(collection string, query []map[string]interface{}) error {
	if ids, err := fetchIds(query); err != nil {
		return err
	} else {
		if err := m.DestroyMany(collection, ids); err != nil {
			return err
		} else {
			return m.CreateMany(collection, query)
		}
	}
}

func (m *modelManager) Count(collection string) (uint, error) {
	if r, err := m.query("collection/count", collection, nil, nil); err != nil {
		return 0, err
	} else {
		if f, ok := r.(float64); !ok {
			return 0, fmt.Errorf("Model count failed for %s. Could not parse %s as a number", collection, r)
		} else {
			return uint(f), nil
		}
	}
}

// goes through the fields in the query and retrieves their _id fields, returning them.
// The query is not modified
func fetchIds(query []map[string]interface{}) ([]string, error) {
	var ret []string

	for _, v := range query {
		if id, ok := v["_xsid"]; !ok {
			return nil, fmt.Errorf("Unable to find _xsid field in json %v", v)
		} else if cast, ok := id.(string); !ok {
			return nil, fmt.Errorf("Model _xsid fields must be strings. Got %v", cast)
		} else {
			ret = append(ret, cast)
		}
	}

	return ret, nil
}

func createIdFilter(query []map[string]interface{}) (interface{}, error) {
	if ids, err := fetchIds(query); err != nil {
		return nil, err
	} else {
		return map[string]interface{}{"_xsid": map[string]interface{}{"$in": ids}}, nil
	}
}
