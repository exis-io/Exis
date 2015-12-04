package goriffle

import "fmt"

// joinRealmCRA joins a WAMP realm and handles challenge/response authentication.
func (c *domain) joinRealmCRA(realm string, details map[string]interface{}) (map[string]interface{}, error) {
	authmethods := []interface{}{}
	for m := range c.Auth {
		authmethods = append(authmethods, m)
	}
	details["authmethods"] = authmethods
	if err := c.Send(&hello{Realm: realm, Details: details}); err != nil {
		c.connection.Close()
		return nil, err
	}
	if msg, err := getMessageTimeout(c.connection, c.ReceiveTimeout); err != nil {
		c.connection.Close()
		return nil, err
	} else if challenge, ok := msg.(*challenge); !ok {
		c.Send(abortUnexpectedMsg)
		c.connection.Close()
		return nil, fmt.Errorf(formatUnexpectedMessage(msg, cHALLENGE))
	} else if authFunc, ok := c.Auth[challenge.AuthMethod]; !ok {
		c.Send(abortNoAuthHandler)
		c.connection.Close()
		return nil, fmt.Errorf("no auth handler for method: %s", challenge.AuthMethod)
	} else if signature, authDetails, err := authFunc(details, challenge.Extra); err != nil {
		c.Send(abortAuthFailure)
		c.connection.Close()
		return nil, err
	} else if err := c.Send(&authenticate{Signature: signature, Extra: authDetails}); err != nil {
		c.connection.Close()
		return nil, err
	}
	if msg, err := getMessageTimeout(c.connection, c.ReceiveTimeout); err != nil {
		c.connection.Close()
		return nil, err
	} else if welcome, ok := msg.(*welcome); !ok {
		c.Send(abortUnexpectedMsg)
		c.connection.Close()
		return nil, fmt.Errorf(formatUnexpectedMessage(msg, wELCOME))
	} else {
		go c.Receive()
		return welcome.Details, nil
	}
}
