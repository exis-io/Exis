package core

import "sync"

var SHARD_COUNT = 10

// A sharded concurrent map with internal RW locks
type ConcurrentMap []*ConcurrentMapShared

// A "thread" safe string to anything map.
type ConcurrentMapShared struct {
	items map[uint64]interface{}
	sync.RWMutex
}

type Tuple struct {
	Key uint64
	Val interface{}
}

// Map of type [uint64: interface{}]
func NewConcurrentMap() ConcurrentMap {
	m := make(ConcurrentMap, SHARD_COUNT)
	for i := 0; i < SHARD_COUNT; i++ {
		m[i] = &ConcurrentMapShared{items: make(map[uint64]interface{})}
	}
	return m
}

// Returns shard under given key
func (m ConcurrentMap) GetShard(key uint64) *ConcurrentMapShared {
	Debug("Before Shard")
    k := m[key%uint64(SHARD_COUNT)]
    Debug("After Shard")

    return k
}

// Sets the given value under the specified key.
func (m *ConcurrentMap) Set(key uint64, value interface{}) {
	// Get map shard.
	shard := m.GetShard(key)
	shard.Lock()
	defer shard.Unlock()
	shard.items[key] = value
}

// Retrieves an element from map under given key.
func (m ConcurrentMap) Get(key uint64) (interface{}, bool) {
	// Get shard
	shard := m.GetShard(key)
	shard.RLock()
	defer shard.RUnlock()

	// Get item from shard.
	val, ok := shard.items[key]
	return val, ok
}

// Returns the number of elements within the map.
func (m ConcurrentMap) Count() int {
	count := 0
	for i := 0; i < SHARD_COUNT; i++ {
		shard := m[i]
		shard.RLock()
		count += len(shard.items)
		shard.RUnlock()
	}
	return count
}

// Looks up an item under specified key
func (m *ConcurrentMap) Has(key uint64) bool {
	shard := m.GetShard(key)
	shard.RLock()
	defer shard.RUnlock()

	_, ok := shard.items[key]
	return ok
}

// Removes an element from the map.
func (m *ConcurrentMap) RemoveKey(key uint64) {
	shard := m.GetShard(key)
	shard.Lock()
	defer shard.Unlock()
	delete(shard.items, key)
}

// Remove an element by value and return it
// func (m *ConcurrentMap) RemoveValue(v interface{}) {
// 	// Try to get shard.
// 	shard := m.GetShard(key)
// 	shard.Lock()
// 	defer shard.Unlock()
// 	delete(shard.items, key)
// }

// Checks if map is empty.
func (m *ConcurrentMap) IsEmpty() bool {
	return m.Count() == 0
}

// Returns a buffered iterator which could be used in a for range loop.
func (m ConcurrentMap) Iter() <-chan Tuple {
	ch := make(chan Tuple, 10)
	go func() {
		// Foreach shard.
		for _, shard := range m {
			// Foreach key, value pair.
			shard.RLock()
			for key, val := range shard.items {
				ch <- Tuple{key, val}
			}
			shard.RUnlock()
		}
		close(ch)
	}()
	return ch
}

func (m ConcurrentMap) Items() map[uint64]interface{} {
	tmp := make(map[uint64]interface{})

	// Insert items to temporary map.
	for item := range m.Iter() {
		tmp[item.Key] = item.Val
	}

	return tmp
}

// Specialized forms of the concurrent map
type BindingConcurrentMap struct {
	ConcurrentMap
}

type BindingTuple struct {
	Key uint64
	Val *boundEndpoint
}

// Map of type [uint64: *boundEndpint]
func NewConcurrentBindingMap() BindingConcurrentMap {
	return BindingConcurrentMap{NewConcurrentMap()}
}

func (m BindingConcurrentMap) Iter() <-chan BindingTuple {
	ch := make(chan BindingTuple, 10)
	go func() {
		for _, shard := range m.ConcurrentMap {
			shard.RLock()

			for key, val := range shard.items {
				ch <- BindingTuple{key, val.(*boundEndpoint)}
			}

			shard.RUnlock()
		}

		close(ch)
	}()
	return ch
}

// Sets the given value under the specified key.
func (m *BindingConcurrentMap) Set(key uint64, value *boundEndpoint) {
	// Get map shard.
	shard := m.GetShard(key)
	shard.Lock()
	defer shard.Unlock()
	shard.items[key] = value
}

// Retrieves an element from map under given key.
func (m BindingConcurrentMap) Get(key uint64) (*boundEndpoint, bool) {
	// Get shard
	shard := m.GetShard(key)
	shard.RLock()
	defer shard.RUnlock()

	// Get item from shard.
	if val, ok := shard.items[key]; ok {
		return val.(*boundEndpoint), true
	} else {
		return nil, false
	}
}

// Get the given binding given its endpoint. Returns its key, binding, and found
func (m BindingConcurrentMap) GetWithEndpoint(endpoint string) (uint64, *boundEndpoint, bool) {
	for _, shard := range m.ConcurrentMap {
		shard.RLock()

		for key, val := range shard.items {
			v := val.(*boundEndpoint)

			if v.endpoint == endpoint {
				shard.RUnlock()
				return key, v, true
			}
		}

		shard.RUnlock()
	}

	return 0, nil, false
}
