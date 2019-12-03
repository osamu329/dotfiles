package main

import (
    "fmt"
    "io/ioutil"
    "encoding/json"
    "bytes"
    "path/filepath"
    "os"
    "flag"
    "log"
    "net/http"
    "net/url"
    "strings"
)

var (
    email string
    dryrun bool
    endpoint string
    hostname string
    username string
    password string
    secretpath string
)

func init() {
    default_secretpath := filepath.Join(os.Getenv("HOME"), ".dotfiles/secrets/google.domains.json")
    flag.StringVar(&hostname, "hostname", "", "`yourhost.yourdomain` (e.g. yourhost.yourdomain) REQUIRED")
    flag.BoolVar(&dryrun, "dry-run", false, "dry run")
    flag.StringVar(&secretpath, "secret", default_secretpath, "secret json `path`")
    flag.StringVar(&email, "email", "", "`email` address included in request body")
    flag.StringVar(&endpoint, "endpoint", "https://domains.google.com/nic/update", "endpoint `URL`")
    flag.StringVar(&username, "user", "", "username")
    flag.StringVar(&password, "password", "", "password")

    flag.Usage = func() {
        fmt.Fprintf(flag.CommandLine.Output(), "Usage of %s:\n", os.Args[0])
        flag.PrintDefaults()
    }
}


type Secret struct {
    Email string
    Domains map[string]UserInfo
}

type UserInfo struct {
    Username string
    Password string
}


func loadSecret(hostname string) (*url.Userinfo, error) {
    // secret json を読み込み
    bs, err := ioutil.ReadFile(secretpath)
    if err != nil {
        // ない場合は、--username と --password から構築を試みる
        if username != "" && password != "" {
            return url.UserPassword(username, password), nil
        }
        return nil, fmt.Errorf("no secret json, please provide --username and --password")
    }

    var secret Secret
    err = json.Unmarshal(bs, &secret)
    if err != nil {
        return nil, err
    }
    email = secret.Email
    ui, ok := secret.Domains[hostname]
    if !ok {
        return nil, fmt.Errorf("hostname:%q not found in secret json", hostname)
    }
    return url.UserPassword(ui.Username, ui.Password), nil
}


func post(userinfo *url.Userinfo) error {
    u, err := url.Parse(endpoint)
    if err != nil {
        return fmt.Errorf("invalid endpoint URL: %s", err)
    }
    u.RawQuery = url.Values{
        "offline": {"no"},
        "hostname": {hostname},
    }.Encode()
    log.Printf("POST %s", u)
    log.Printf("     %s", email)
    u.User = userinfo

    body := strings.NewReader(email)
    req, err := http.NewRequest("POST", u.String(), body)
    if err != nil {
        return err
    }
    req.Header.Set("User-Agent", "Chrome/41.0")

    if dryrun {
        log.Printf("dry-run ok")
        return nil
    }

    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        return err
    }
    defer resp.Body.Close()
    log.Printf("%s\n",resp.Status)
    b := &bytes.Buffer{}
    b.ReadFrom(resp.Body)
    log.Printf("%s\n", b.String())
    return nil
}

func run() int {
    userinfo, err := loadSecret(hostname)
    if err != nil {
        log.Printf("failed to read secret: %s", err)
        return 1
    }
    err = post(userinfo)
    if err != nil {
        return 1
    }
    return 0
}

func main() {
    flag.Parse()
    if hostname == "" {
        fmt.Printf("ERROR: hostname is not provieded.\n")
        flag.Usage()
        fmt.Printf("\n")
        fmt.Printf("Example:\n")
        fmt.Printf(" ddnsupdate yourhost.yourdomain\n\n")
        os.Exit(2)
    }
    os.Exit(run())
}
