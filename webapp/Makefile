OS=$(shell uname -s)
ARCH=$(shell uname -m)
COMMIT_HASH=$(shell git rev-parse HEAD)
WEBHOOK_URL=$(shell cat .env | grep WEBHOOK_URL | cut -d '=' -f 2)
IP_ADDRESS1=$(shell cat .env | grep IP_ADDRESS1 | cut -d '=' -f 2)
IP_ADDRESS2=$(shell cat .env | grep IP_ADDRESS2 | cut -d '=' -f 2)
IP_ADDRESS3=$(shell cat .env | grep IP_ADDRESS3 | cut -d '=' -f 2)

prepare:
	ssh -i ~/.ssh/id_ed25519 isucon@$(IP_ADDRESS1) "echo -n > /var/log/mysql/mysql-slow.log"
	ssh -i ~/.ssh/id_ed25519 isucon@$(IP_ADDRESS1) "echo -n > /var/log/nginx/access.log"
	ssh -i ~/.ssh/id_ed25519 isucon@$(IP_ADDRESS2) "echo -n > /var/log/mysql/mysql-slow.log"
	ssh -i ~/.ssh/id_ed25519 isucon@$(IP_ADDRESS2) "echo -n > /var/log/nginx/access.log"
	ssh -i ~/.ssh/id_ed25519 isucon@$(IP_ADDRESS3) "echo -n > /var/log/mysql/mysql-slow.log"
	ssh -i ~/.ssh/id_ed25519 isucon@$(IP_ADDRESS3) "echo -n > /var/log/nginx/access.log"

analyze:
	make slowquery & make accesslog

slowquery: log bin/pt-query-digest
	rm log/slow.log log/analyzed-slow.log
	scp -i ~/.ssh/id_ed25519 isucon@$(IP_ADDRESS1):/var/log/mysql/mysql-slow.log log/slow.log
	./bin/pt-query-digest log/slow.log > log/analyzed-slow.log
	curl -X POST -H 'Content-Type: multipart/form-data' -F 'payload_json={"username": "slow query$(IP_ADDRESS1)", "content": "commit hash: $(COMMIT_HASH) \n IP: $(IP_ADDRESS1)"}' -F 'file=@log/analyzed-slow.log' $(WEBHOOK_URL)

	rm log/slow.log log/analyzed-slow.log
	scp -i ~/.ssh/id_ed25519 isucon@$(IP_ADDRESS2):/var/log/mysql/mysql-slow.log log/slow.log
	./bin/pt-query-digest log/slow.log > log/analyzed-slow.log
	curl -X POST -H 'Content-Type: multipart/form-data' -F 'payload_json={"username": "slow query$(IP_ADDRESS2)", "content": "commit hash: $(COMMIT_HASH) \n IP: $(IP_ADDRESS2)"}' -F 'file=@log/analyzed-slow.log' $(WEBHOOK_URL)

	rm log/slow.log log/analyzed-slow.log
	scp -i ~/.ssh/id_ed25519 isucon@$(IP_ADDRESS3):/var/log/mysql/mysql-slow.log log/slow.log
	./bin/pt-query-digest log/slow.log > log/analyzed-slow.log
	curl -X POST -H 'Content-Type: multipart/form-data' -F 'payload_json={"username": "slow query$(IP_ADDRESS3)", "content": "commit hash: $(COMMIT_HASH) \n IP: $(IP_ADDRESS3)"}' -F 'file=@log/analyzed-slow.log' $(WEBHOOK_URL)

accesslog: log bin/alp
	scp -i ~/.ssh/id_ed25519 isucon@$(IP_ADDRESS1):/var/log/nginx/access.log log/access.log
	./bin/alp json \
	  --sort sum -r \
	  -m "/posts/[0-9]+,/@\w+,/image/\d+" \
	  -o count,method,uri,min,avg,max,sum \
	  < log/access.log > log/analyzed-access.log
	curl -X POST -H 'Content-Type: multipart/form-data' -F 'payload_json={"username": "alp$(IP_ADDRESS1)", "content": "commit hash: $(COMMIT_HASH) \n IP: $(IP_ADDRESS1)"}' -F 'file=@log/analyzed-access.log' $(WEBHOOK_URL)

	scp -i ~/.ssh/id_ed25519 isucon@$(IP_ADDRESS2):/var/log/nginx/access.log log/access.log
	./bin/alp json \
	  --sort sum -r \
	  -m "/posts/[0-9]+,/@\w+,/image/\d+" \
	  -o count,method,uri,min,avg,max,sum \
	  < log/access.log > log/analyzed-access.log
	curl -X POST -H 'Content-Type: multipart/form-data' -F 'payload_json={"username": "alp$(IP_ADDRESS2)", "content": "commit hash: $(COMMIT_HASH) \n IP: $(IP_ADDRESS2)"}' -F 'file=@log/analyzed-access.log' $(WEBHOOK_URL)

	scp -i ~/.ssh/id_ed25519 isucon@$(IP_ADDRESS3):/var/log/nginx/access.log log/access.log
	./bin/alp json \
	  --sort sum -r \
	  -m "/posts/[0-9]+,/@\w+,/image/\d+" \
	  -o count,method,uri,min,avg,max,sum \
	  < log/access.log > log/analyzed-access.log
	curl -X POST -H 'Content-Type: multipart/form-data' -F 'payload_json={"username": "alp$(IP_ADDRESS3)", "content": "commit hash: $(COMMIT_HASH) \n IP: $(IP_ADDRESS3)"}' -F 'file=@log/analyzed-access.log' $(WEBHOOK_URL)

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

# /etc/nginx/nginx.confでlogをjson形式にする(全てのサーバー) 
# nginx -tで構文チェック systemctl reload nginxで再起動

# slow queryログを有効にする(全てのサーバー)
# sudo systemctl restart mysqlで再起動

# isuconユーザーでアクセスできるよう以下のファイルのパーミッションを変更する(全てのサーバー)
# chmod 777 /var/log/mysql
# chmod 777 /var/log/mysql/mysql-slow.log
# chmod 777 /var/log/nginx/access.log

# 実行順序はデプロイ -> make prepare　-> ベンチ実行 -> make analyze
