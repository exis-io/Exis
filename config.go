package riffle

import (
	"encoding/json"
	"io/ioutil"
)

type NodeConfig struct {
	Agent         string
	RequestLimits [][]interface{}
}

func LoadConfig(path string) (*NodeConfig, error) {
	file, err := ioutil.ReadFile(path)
	if err != nil {
		out.Critical("Loading configuration file failed: %s", err)
		return nil, err
	}

	var config NodeConfig
	err = json.Unmarshal(file, &config)
	if err != nil {
		out.Critical("Parsing configuration file failed: %s", err)
		return nil, err
	}

	out.Debug("Loaded configuration file: %s", path)
	return &config, nil
}

// Get request limit from configuration file.
// This is the number of requests (per second) a domain is allowed to make.
//
// Entries are checked in order, and the first entry that contains (equal to or
// larger than) the given domain is taken.
//
// Be sure to include a default in the configuration file, e.g. ["", 100] as
// the last entry.
func (config *NodeConfig) GetRequestLimit(domain string) int {
	for _, entry := range config.RequestLimits {
		// entry should be ["domain", limit]
		entryDomain, _ := entry[0].(string)
		entryLimit := int(entry[1].(float64))

		if entryDomain == "" || subdomain(entryDomain, domain) {
			return entryLimit
		}
	}

	out.Critical("No default request limit defined: returning 1")
	return 1
}
