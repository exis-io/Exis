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

// Get a domain name and authentication token by presenting a list of credentials.
// This token is presented to the fabric during App.Connect() and is given to the app
// with App.SetToken(). Get the current token with App.GetToken().
//
// Takes a list of strings cast to []interface{} of length 0, 1, or 2.
// when len(args) is...
//      0, args is []
//      1, args must be [username]
//      2, args must be [username, password]
//
// Returns the token and the domain name authenticated with.
//
// Subsequent login attempts will not always succeed-- the crust is expected
// to persist the token after a login success and set it with App.GetToken().
//
// The number of credentials depends on the Auth appliance attached to this app. This app is
// identified by app.agent or App.GetAgent() and is set when App is constructed.
// when the auth level is...
//      0: password not needed. Username optional; if not included the Auth randomly generates one
//      1: username and password are both required
//
// If HardAuthentication = false, which is automatically the case when SetFabricDev() or SetFabricSandbox()
// is called, this method will always suceed with a username and fail without one. Random
// usernames are assigned by Auth-- without HardAuthentication there's no auth to create the name.
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

	if !HardAuthentication {
		if username != "" {
			a.agent = a.appDomain + "." + username
			return "", a.agent, nil
		} else {
			return "", "", fmt.Errorf("You are connecting to a fabric that does not have auth. Login requires a name to authenticate with. Please pass as username.")
		}
	}

	payload := map[string]interface{}{"domain": username, "password": password, "requestingdomain": a.appDomain}

	if result, err := jsonPost(Registrar+"/login", payload); err != nil {
		return "", "", err
	} else {
		if d, ok := result["domain"]; !ok {
			return "", "", fmt.Errorf("Token authentication failed: could not find key \"domain\" in reply: %v")
		} else {
			a.agent = d.(string)
		}

		if t, ok := result["login_token"]; !ok {
			return "", "", fmt.Errorf("Token authentication failed: could not find login_token key in reply")
		} else {
			a.token = t.(string)
		}

		return a.token, a.agent, nil
	}
}

// Attempts to register with the given credentials. Returns an error if any part of the process failed
// or the registration itself failed. Lack of an error means the operation suceeded.
func (a *app) Register(username string, password string, email string, name string) error {
	Info("Registering as username \"%s\" with name \"%s\"", username, name)

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
