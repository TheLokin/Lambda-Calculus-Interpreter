# Rules for the lambda calculus interpreter
#
# make            to build the executable file main.o, run it and remove all intermediate and temporary files
# make compile    to build the executable file main.o
# make run        to run the executable file main.o
# make clean      to remove all intermediate and temporary files
# make depend     to build the dependency graph between modules that is used by determine in what order
#                 to compile. This shouldn't need to be done unless new modules are added between
#                 existing modules. The dependency graph is stored in the file .depend

# These are object files needed to build the main executable file
OBJS = utils.cmo syntax.cmo church.cmo print.cmo types.cmo lambda.cmo parser.cmo lexer.cmo main.cmo

# These are files that need to be generated from other files
DEPEND = lexer.ml parser.ml

# Build the executable file main.o, run it and remove all intermediate and temporary files
all : compile run clean

# Include an automatically generated list of dependencies between source files
include .depend

# Build the executable file main.o
compile : $(DEPEND) $(OBJS)
	ocamlc -o main.o $(OBJS)

# Compile an ocaml module interface
%.cmi : %.mli
	ocamlc -c $<

# Compile an ocaml module implementation
%.cmo : %.ml
	ocamlc -c $<

# Generate ocaml files from a parser definition file
parser.ml parser.mli : parser.mly
	@rm -f parser.ml parser.mli
	ocamlyacc parser.mly
	@chmod -w parser.ml parser.mli

# Generate ocaml files from a lexer definition file
%.ml %.mli : %.mll
	@rm -f $@
	ocamllex $<
	@chmod -w $@

# Run the executable file main.o
run :
	rlwrap ./main.o

# Remove all intermediate and temporary files
clean :
	rm -rf parser.ml parser.mli lexer.ml *.o *.cmo *.cmi

# Build the dependency graph between modules
depend : $(DEPEND)
	ocamldep *.mli *.ml > .depend