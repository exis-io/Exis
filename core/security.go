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

// Attempts to obtain a token and a domain with the given credentials. Does not call Connect on the app.
// Pass a list of 0, 1, or 2 arguments: [username, password] based on the type of authentication for this app
// Returns the token and domain name as strings when successful
func (a *app) Login(args []interface{}) (string, string, error) {
	username, password := "", ""

	if len(args) == 2 {
		username = args[0].(string)
		password = args[1].(string)
	} else if len(args) == 1 {
		username = args[0].(string)
	} else if len(args) != 0 {
		return "", "", fmt.Errorf("Login must be called with 0, 1 or 2 arguments. ([username [, password]]).")
	}

	Info("Logging in as \"%s\"", username)

	// This is set manually or when the fabric is selected
	if !HardAuthentication {
		if username == "" {
			return "", "", fmt.Errorf("You are connecting to a fabric that does not have auth. Login requires a name to authenticate with. Please pass as username.")
		}

		a.agent = a.appDomain + "." + username
		return "", a.agent, nil
	}

	if token, agent, err := tokenLogin(a.appDomain, username, password); err != nil {
		return "", "", err
	} else {
		a.token = token
		a.agent = agent
		return a.token, a.agent, nil
	}
}

// Attempts to register with the given credentials. Returns an error if any part of the process failed
// or the registration itself failed
func (a *app) Register(username string, password string, email string, name string) error {
	Info("Registering as username \"%s\" with name \"%s\"", username, name)

	// This is set manually or when the fabric is selecte
	if !HardAuthentication {
		return nil
	}

	_, err := jsonPost(Registrar+"/register", map[string]interface{}{
		"domain":           username,
		"domain-password":  password,
		"requestingdomain": a.appDomain,
		"domain-email":     email,
		"Name":             name,
	})

	return err
}

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

// Gets the current token
func (a *app) GetToken() string {
	return a.token
}

// Reads in the key path provided to set the app key
func (a *app) LoadKey(p string) error {
	if buf, err := ioutil.ReadFile(p); err != nil {
		Error("Unable to find key: %s", p)
		return err
	} else {
		a.key = string(buf)
	}

	return nil
}

// Attempt a token login. Returns token and name on success
func tokenLogin(domain string, username string, password string) (string, string, error) {
	Info("Token authentication requested as username %s from domain %s", username, domain)
	payload := map[string]interface{}{"domain": username, "password": password, "requestingdomain": domain}

	if result, err := jsonPost(Registrar+"/login", payload); err != nil {
		return "", "", err
	} else {
		var name, token interface{}
		var ok bool

		if name, ok = result["domain"]; !ok {
			return "", "", fmt.Errorf("Token authentication failed: could not find key \"domain\" in reply: %v")
		}

		if token, ok = result["login_token"]; !ok {
			return "", "", fmt.Errorf("Token authentication failed: could not find login_token key in reply")
		}

		return token.(string), name.(string), nil
	}
}

// Sends an HTTP post, turning off SSL if global UseUnsafeCert is set. Returns an error if the
// response code is not 200, else the results decoded as a json
func jsonPost(url string, arguments map[string]interface{}) (map[string]interface{}, error) {
	var resp *http.Response
	var postErr error
	var payload *bytes.Buffer

	Debug("Posting to: (%s) json: %v", url, arguments)

	if j, err := json.Marshal(arguments); err != nil {
		return nil, err
	} else {
		payload = bytes.NewBuffer(j)
	}

	if UseUnsafeCert {
		client := &http.Client{Transport: &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		}}

		resp, postErr = client.Post(url, "application/x-www-form-urlencoded", payload)
	} else {
		resp, postErr = http.Post(url, "application/x-www-form-urlencoded", payload)
	}

	if postErr != nil {
		return nil, postErr
	} else {
		defer resp.Body.Close()
		body, _ := ioutil.ReadAll(resp.Body)

		if resp.StatusCode != 200 {
			return nil, fmt.Errorf(string(body))
		}

		// Successful registrations have an empty body
		if len(body) == 0 {
			return make(map[string]interface{}), nil
		}

		var result map[string]interface{}
		if err := json.Unmarshal(body, &result); err != nil {
			return nil, err
		} else {
			return result, nil
		}
	}
}
