package riffle

import (
	"time"
)

type Limiter interface {
	Acquire()
	Refresh()
}

type BasicLimiter struct {
	limit int

	available   int
	windowStart int64

	throttle chan int
}

func NewBasicLimiter(limit int) BasicLimiter {
	limiter := BasicLimiter{
		limit:       limit,
		available:   limit,
		windowStart: time.Now().Unix(),
	}
	return limiter
}

func (limiter *BasicLimiter) Acquire() {
	if limiter.available > 0 {
		limiter.available--
		return
	}

	if limiter.throttle == nil {
		now := time.Now().Unix()
		if (now - limiter.windowStart) >= 1 {
			limiter.available = limiter.limit - 1
			limiter.windowStart = now
		} else {
			// Exceeded limit within time window.
			// Add it to the throttle list.
			limiter.throttle = make(chan int)
			go limiter.Refresh()
		}
	} else {
		allowed := <-limiter.throttle
		limiter.available += allowed - 1
	}
}

func (limiter *BasicLimiter) Refresh() {
	for {
		time.Sleep(time.Second)
		limiter.throttle <- limiter.limit
	}
}
