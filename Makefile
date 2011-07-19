.PHONY: compile xref eunit clean doc check make deps

all: compile xref eunit

# for busy typos
m: all
ma: all
mak: all
make: all

deps:
	@./rebar check-deps
	@./rebar get-deps
	@./rebar update-deps

compile: deps
	@./rebar compile

xref:
	@./rebar xref

eunit: compile
	@./rebar eunit

clean:
	@./rebar clean

doc:
	@./rebar doc

check:
	@echo "you need ./rebar build-plt before make check"
# @./rebar build-plt
	@./rebar check-plt
	@./rebar dialyze

crosslang:
	@echo "do ERL_LIBS=../ before you make crosslang or fail"
	cd test && make crosslang
