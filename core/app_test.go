package core

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

//
// Below is a test RSA key for validating our CRA implementation.  This key is
// not used anywhere else.
//
// Here are commands used to generate the key and signature.  NONCE is an
// arbitrary string.
//
//  openssl genrsa 1024 >key
//  echo -n "$NONCE" | openssl dgst -sha512 -sign key | base64
//

const TEST_RSA_PRIVATEKEY = `-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQDsta8395NaYBGjlZX5OWpnzg+/3TjPI92QucceYyE44sGT+v7A
GlU0cIKm5GBRPp7ubYNK3jdnNE6R5VMg4xNG5mZhEXH5f00njx7WJuaDOU9xl5U2
O65c/Sv0hr3wflM0HMjCX2mXx2hTdJn7zrdgl+uTgbcOEDDVbRwoPb1ZswIDAQAB
AoGAN4ZixKEZepCgcpvrIxv5vsHSZfIxmj1SgtlhQNqF938RY3H0AgHrTLK7owRd
J5Gl3E3qB0za+CWH7Kc7ebJqWbrBGqcGQgw9FYbt/ZyGM1pSc9YAzzdMusxq4jnl
7iAyz1NeE2fvC1VMfhYKHRjq5hY/ysQIXwfQqfun3ReM81ECQQD5AU7bZlmHfWf5
Fv0AqHWMX0iKv4IY31ittbV1s4Ty/FkYp9ZgsQOrxgVwm+vNaHhzHA53dZLM8jiP
e+97oATpAkEA81v0lYQfJu+kV5uyikcMQFmVzO2YsNKctljG+Mq9gZC26Q+9e/Uf
c3In31H0tgWiqrMG4hIjHhTEqPkVg7d4OwJBAJcbtxon228AqIcd7z1l/afI7wHc
Q/wKFgucuNkLr0Ox5fOzbsJQydSFICn9RTTrECVywki2Xfbni3FvmZ5hNnkCQBDm
NtLXLO6gP5JR3pEZo/EoB24Gpc7JoVZMTezi70v7B6ihji/4cqmqqLgqUcr+EzC1
Y+n5BnVFTe7J9UODTxcCQAqvUgEHcqVNWBtZvj+x7lJu8CBTSBhJdwpWSmn8XHXM
ej+5oD+qye40cr8TtCvf0nLN4K7ilLeyJYYpAImy6uE=
-----END RSA PRIVATE KEY-----`

const TEST_RSA_PUBLICKEY = `-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDsta8395NaYBGjlZX5OWpnzg+/
3TjPI92QucceYyE44sGT+v7AGlU0cIKm5GBRPp7ubYNK3jdnNE6R5VMg4xNG5mZh
EXH5f00njx7WJuaDOU9xl5U2O65c/Sv0hr3wflM0HMjCX2mXx2hTdJn7zrdgl+uT
gbcOEDDVbRwoPb1ZswIDAQAB
-----END PUBLIC KEY-----`

const TEST_NONCE = "govZ7gMUU.VXa5dtt-IJsFwI4WHOZCPJMLps5SHg6.68BgUd1ZaZzsxSAoOEq-1mad0sWL5lY09cATNIpr5E1jZwKnisxBifMM4wf1S4qw.-rihgIMgnMFrENVKd6a7cTC5XwVwWU.pW6stXd4GDYcRL4.q7m6ONrXvW4sk4uTk_"

const TEST_SIGNATURE = "FnUriKgaOCjm4aBmASHK+DQ/N4Kg+UgAtZ67XJvYvidbtrFSiKOmwHPQPRLkcwjZodLowWfZ1zJ32sLJ8ZSr43wPGIeqUCUOcC6P+ie1zAthGkKOjbv2CsvfdIAjROYXkN9lDDuvQhRdB9XqrZcPGNeTzwcVddY39GuzNz8UEJE="

func TestSigning(t *testing.T) {
	Convey("Decoding private key", t, func() {
		Convey("Should produce rsa.PrivateKey object", func() {
			_, err := DecodePrivateKey([]byte(TEST_RSA_PRIVATEKEY))
			So(err, ShouldBeNil)
		})

		Convey("Should fail for junk data", func() {
			_, err := DecodePrivateKey([]byte("aoeu"))
			So(err, ShouldNotBeNil)
		})

		Convey("Should fail for public key", func() {
			_, err := DecodePrivateKey([]byte(TEST_RSA_PUBLICKEY))
			So(err, ShouldNotBeNil)
		})
	})

	Convey("Signing a message", t, func() {
		Convey("Should produce correct signature", func() {
			key, _ := DecodePrivateKey([]byte(TEST_RSA_PRIVATEKEY))
			sig, _ := SignString(TEST_NONCE, key)
			So(sig, ShouldEqual, TEST_SIGNATURE)
		})
	})
}
