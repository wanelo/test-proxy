package main

import (
	"flag"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
)

func main() {
	port := flag.String("port", "8080", "Specifies which port to proxy in front of")
	cert := flag.String("cert", "cert.pem", "Absolute path to cert.pem")
	key := flag.String("key", "key.pem", "Absolute path to key.pem")
	verbose := flag.Bool("verbose", false, "Log requests to stdout")

	flag.Parse()

	log.Println("Proxying port: " + *port)
	log.Println("Loading cert at: " + *cert)
	log.Println("Loading key at: " + *key)

	remote, err := url.Parse("http://localhost:" + *port)
	if err != nil {
		panic(err)
	}

	proxy := httputil.NewSingleHostReverseProxy(remote)
	http.HandleFunc("/", handler(proxy, verbose))

	go func() {
		err = http.ListenAndServe(":80", nil)
		if err != nil {
			panic(err)
		}
	}()

	err = http.ListenAndServeTLS(":443", *cert, *key, nil)
	if err != nil {
		panic(err)
	}
}

func handler(p *httputil.ReverseProxy, verbose *bool) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		var protocol string
		if r.TLS != nil {
			protocol = "https"
		} else {
			protocol = "http"
		}

    if *verbose {
      log.Println(r.Method, protocol, r.URL)
    }

		r.Header.Add("X-Forwarded-Proto", protocol)
		r.Header.Add("Host", r.Host)
		p.ServeHTTP(w, r)
	}
}
