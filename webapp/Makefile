OS=$(shell uname -s)
ARCH=$(shell uname -m)
COMMIT_HASH=$(shell git rev-parse HEAD)
WEBHOOK_URL=$(shell cat .env | grep WEBHOOK_URL | cut -d '=' -f 2)

prepare:
	ssh -i ~/.ssh/id_ed25519 isucon@54.249.186.113 "echo -n > /var/log/mysql/mysql-slow.log"
	ssh -i ~/.ssh/id_ed25519 isucon@54.249.186.113 "echo -n > /var/log/nginx/access.log"

analyze:
	make slowquery & make accesslog

slowquery: log bin/pt-query-digest
	scp -i ~/.ssh/id_ed25519 isucon@54.249.186.113:/var/log/mysql/mysql-slow.log log/slow.log
	./bin/pt-query-digest log/slow.log > log/analyzed-slow.log
	curl -X POST -H 'Content-Type: multipart/form-data' -F 'payload_json={"username": "slow query", "content": "commit hash: $(COMMIT_HASH)"}' -F 'file=@log/analyzed-slow.log' $(WEBHOOK_URL)

accesslog: log bin/alp
	scp -i ~/.ssh/id_ed25519 isucon@54.249.186.113:/var/log/nginx/access.log log/access.log
	./bin/alp json \
	  --sort sum -r \
	  -m "/posts/[0-9]+,/@\w+,/image/\d+" \
	  -o count,method,uri,min,avg,max,sum \
	  < log/access.log > log/analyzed-access.log
	curl -X POST -H 'Content-Type: multipart/form-data' -F 'payload_json={"username": "alp", "content": "commit hash: $(COMMIT_HASH)"}' -F 'file=@log/analyzed-access.log' $(WEBHOOK_URL)

bin/alp: bin
	curl -o bin/alp.zip -L https://github.com/tkuchiki/alp/releases/download/v1.0.21/alp_$(OS)_$(ARCH).zip
	unzip -d bin -o bin/alp.zip
	rm bin/alp.zip
	chmod +x bin/alp

bin/pt-query-digest: bin
	curl -o bin/pt-query-digest -LO percona.com/get/pt-query-digest
	chmod +x bin/pt-query-digest

log:
	mkdir log

bin:
	mkdir bin
