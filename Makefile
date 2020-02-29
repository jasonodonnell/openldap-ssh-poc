.PHONY: all 
all: run

run:
	$(PWD)/run.sh

test:
	$(PWD)/test.sh

clean:
	$(PWD)/cleanup.sh
