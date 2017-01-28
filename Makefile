.PHONY: all check accept

test_dir = test

all:
	@echo "Run 'make check' to check against the current baseline and 'make accept' to set a new baseline from the last results."

accept:
	@mv $(test_dir)/round_robin_latest.txt $(test_dir)/round_robin_baseline.txt

check:
	@dart bin/round_robin.dart --mode=test > $(test_dir)/round_robin_latest.txt && diff -U 7 $(test_dir)/round_robin_baseline.txt $(test_dir)/round_robin_latest.txt

