# Tesla API proxy
This is a PoC app inspired by this [Reddit thread](https://www.reddit.com/r/teslamotors/comments/9joh3c/ill_build_your_unofficial_tesla_owner_app_or/e6tyix7/).

## Installation
- `git clone https://github.com/f3ath/tesla-proxy`


## Running the server
### Locally
- `pub install`
- `pub run tesla_proxy:server -t <token>`

### With Docker
- Build: `docker build -t proxy .`
- Run: `docker run -e TESLA_TOKEN=<token> -d -p 8080:8080 proxy`