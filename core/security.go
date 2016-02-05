package core

import (
	"bytes"
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha512"
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

// Gets the current token
func (a *app) GetToken() (string) {
	return a.token
}

//takes the domain that login was called on and then 0-2 strings which correspond to username and password
func (a *app) Login(d Domain, args ...string) (Domain, error){
    username := ""
    password := ""

    if len(args) == 2 {
		username = args[0]
		password = args[1]
    } else if len(args) == 1 {
		username = args[0]
    } else if len(args) != 0 {
		return nil, fmt.Errorf("Login must be called with 0,1 or 2 args. ([username [, password]]).")
    }
    if Fabric == FabricSandbox {
	if username == "" {
	    return d, nil
	}else {
	    return d.Subdomain(username), nil
	}
    }

    if token, domain, err := tokenLogin(d.GetName(), username, password ); err != nil{
		return nil, err
    } else {
		a.SetToken(token)
		return d.LinkDomain(domain), nil
    }
    return nil, nil
}

//takes the domain that register was called on and registration info required by Auth
func (a *app) RegisterAccount(d Domain, username string, password string, email string, name string ) (bool, error){
	if Fabric == FabricSandbox {
	    return false, fmt.Errorf("Registration is not available on the sandbox node.")
	}
	Info("Attempting to register")
	url := Registrar + "/register"

	payload := map[string]interface{}{"domain": username, "domain-password": password, "requestingdomain": d.GetName(), "domain-email": email, "Name": name }
	jsonString, err := json.Marshal(payload)

	if err != nil {
		return false, err
	}

	resp, err := http.Post(url, "application/x-www-form-urlencoded", bytes.NewBuffer(jsonString))

	if err != nil {
	    return false, err
	} else {
		defer resp.Body.Close()
		if resp.StatusCode != 200 {
		    body, _ := ioutil.ReadAll(resp.Body)
		    result := string(body)
		    return false, fmt.Errorf(result)
		} else {
		    return true, nil
		}
	}

	return false, nil
}

// Attempt a token login.
func tokenLogin(domain string, username string, password string) (string, string, error) {
	Info("Attempting to obtain a token")
	url := Registrar + "/login"

	payload := map[string]interface{}{"domain": username, "password": password, "requestingdomain": domain}
	jsonString, err := json.Marshal(payload)

	if err != nil {
		return "", "", err
	}

	if resp, err := http.Post(url, "application/x-www-form-urlencoded", bytes.NewBuffer(jsonString)); err != nil {
		return "", "", err
	} else {
		defer resp.Body.Close()
		if resp.StatusCode != 200 {
		    body, _ := ioutil.ReadAll(resp.Body)
		    result := string(body)
		    return "", "", fmt.Errorf(result)
		}
		body, _ := ioutil.ReadAll(resp.Body)

		var result map[string]interface{}

		if err := json.Unmarshal(body, &result); err != nil {
			return "", "", err
		} else {
		        name, ok := result["domain"]
			if !ok {
			    return "", "", fmt.Errorf("no domain returned")
			}
			if token, ok := result["login_token"]; !ok {
				return "", "", fmt.Errorf("Server error: could not find login_token key in reply")
			} else {
				return token.(string), name.(string), nil
			}
		}
	}

	return "", "", nil
}
