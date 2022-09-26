package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

// Returns hostname, either through env or from host
func getHostname() string {
	hostName := os.Getenv("HOSTNAME")
	if len(hostName) == 0 {
		hostName, _ = os.Hostname()
	}

	return hostName
}

// Returns a uid from env
func getUid() string {
	return os.Getenv("UID")
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	hostName := getHostname()
	uid := getUid()
	w.Header().Set("X-Hostname", hostName)
	w.Header().Set("X-Uid", uid)
	w.Header().Set("Content-Type", "text/plain")

	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "%q: OK\n", hostName)
	log.Printf("(%v) [%v] %q %q %q %q", hostName, uid, r.RemoteAddr, r.Method, r.Host, r.RequestURI)
}

func main() {
	port := os.Getenv("PORT")
	listen := fmt.Sprintf(":%v", port)
	http.HandleFunc("/", rootHandler)
	log.Fatal(http.ListenAndServe(listen, nil))
}
