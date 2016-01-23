package core

import (
	"bytes"
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha512"
	"crypto/tls"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"io/ioutil"
	"net/http"
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

// Attempt a token login. Expects the app domain to be the next domain up (temporary)
// TODO: intelligently parse the superdomain from the given domain
func tokenLogin(domain string) (string, error) {
	Info("Attempting to obtain a token")
	url := "https://node.exis.io:8880/login"

	// Damouse's Ubuntu 14.10 would not accept the certificate. This is dangerous and must be removed
	tr := &http.Transport{TLSClientConfig: &tls.Config{InsecureSkipVerify: true}}

	superdomain, err := getSuperdomain(domain)

	if err != nil {
		return "", err
	}

	payload := map[string]interface{}{"domain": domain, "requestingdomain": superdomain}
	jsonString, err := json.Marshal(payload)

	if err != nil {
		return "", err
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonString))

	if err != nil {
		return "", err
	}

	req.Header.Set("Content-Type", "application/json")
	client := &http.Client{Transport: tr}

	if resp, err := client.Do(req); err != nil {
		return "", err
	} else {
		defer resp.Body.Close()
		body, _ := ioutil.ReadAll(resp.Body)

		var result map[string]interface{}

		if err := json.Unmarshal(body, &result); err != nil {
			return "", err
		} else {
			if token, ok := result["login_token"]; !ok {
				return "", fmt.Errorf("Server error: could not find login_token key in reply")
			} else {
				return token.(string), nil
			}
		}
	}

	return "", nil
}
