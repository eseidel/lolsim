.PHONY: all check-ranks accept-ranks check-spells accept-spells

test_dir = test

all:
	@echo "Run 'make check*' to check against the current baseline and 'make accept*' to set a new baseline from the last results."

accept-ranks:
	@mv $(test_dir)/round_robin_latest.txt $(test_dir)/round_robin_baseline.txt

check-ranks:
	@dart bin/round_robin.dart --mode=test > $(test_dir)/round_robin_latest.txt && diff -U 7 $(test_dir)/round_robin_baseline.txt $(test_dir)/round_robin_latest.txt

accept-spells:
	@mv $(test_dir)/spells_latest.txt $(test_dir)/spells_baseline.txt

check-spells:
	@dart bin/test_spells.dart > $(test_dir)/spells_latest.txt && diff -U 7 $(test_dir)/spells_baseline.txt $(test_dir)/spells_latest.txt

