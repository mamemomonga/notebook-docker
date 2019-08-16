default:
	@echo "USAGE: make [ create | destroy ]"
	@exit 1

create:
	bin/dbms.sh mysql_create
	bin/dbms.sh pgsql_create

destroy:
	bin/dbms.sh mysql_destroy
	bin/dbms.sh pgsql_destroy

.PHONY: create destroy default

