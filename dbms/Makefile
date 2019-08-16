default:
	@echo "USAGE: make [ create | destroy ]"
	@exit 1

create:
	bin/mysql.sh create
	bin/pgsql.sh create

destroy:
	bin/mysql.sh destroy
	bin/pgsql.sh destroy
	rm -f .env

export:
	bin/mysql.sh export 1 mysql-db-1.sql
	bin/mysql.sh export 2 mysql-db-2.sql
	bin/pgsql.sh export 1 pgsql-db-1.sql
	bin/pgsql.sh export 2 pgsql-db-2.sql

import:
	bin/mysql.sh import 1 mysql-db-1.sql
	bin/mysql.sh import 2 mysql-db-2.sql
	bin/pgsql.sh import 1 pgsql-db-1.sql
	bin/pgsql.sh import 2 pgsql-db-2.sql

.PHONY: create destroy default

