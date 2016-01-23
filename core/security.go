package core

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha512"
	"crypto/x509"
	"encoding/base64"
	"encoding/pem"
	"fmt"
)

// All security operations are wrapped up here
// type Security interface {
// 	SetToken(string)
// }

func DecodePrivateKey(data []byte) (*rsa.PrivateKey, error) {
	// Decode the PEM public key
	block, _ := pem.Decode(data)
	if block == nil {
		return nil, fmt.Errorf("Error decoding PEM file")
	}

	// Parse the private key.
	priv, err := x509.ParsePKCS1PrivateKey(block.Bytes)
	if err != nil {
		return nil, err
	}

	return priv, nil
}

func SignString(msg string, key *rsa.PrivateKey) (string, error) {
	hashed := sha512.Sum512([]byte(msg))

	sig, err := rsa.SignPKCS1v15(rand.Reader, key, crypto.SHA512, hashed[:])
	if err != nil {
		return "", err
	}

	result := base64.StdEncoding.EncodeToString(sig)
	return result, nil
}

func (c *app) handleChallenge(msg *challenge) error {
	response := &authenticate{
		Signature: "",
		Extra:     make(map[string]interface{}),
	}

	switch msg.AuthMethod {
	case "token":
		response.Signature = c.token

	case "signature":
		nonce, _ := msg.Extra["challenge"].(string)

		key, err := DecodePrivateKey([]byte(c.key))
		if err != nil {
			return err
		}

		response.Signature, err = SignString(nonce, key)
		if err != nil {
			return err
		}

		// TODO: warn on unrecognized auth method
	}

	c.Send(response)
	return nil
}

func (c *app) getAuthID() string {
	if c.authid == "" {
		return c.agent
	} else {
		return c.authid
	}
}

// Return a list of authentication methods that we support,
// which depends on what credentials were passed.
func (c *app) getAuthMethods() []string {
	authmethods := make([]string, 0)

	if c.key != "" {
		authmethods = append(authmethods, "signature")
	}

	if c.token != "" {
		authmethods = append(authmethods, "token")
	}

	return authmethods
}

// Sets the current authmethod to token and sets the token
func (a *app) SetToken(token string) {
	a.token = token
}
