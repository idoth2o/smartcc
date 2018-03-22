all: parser

OBJS = parser.o  \
       codegen.o \
       corefn.o \
       main.o    \
       tokens.o  \

LLVMCONFIG = llvm-config
CPPFLAGS = `$(LLVMCONFIG) --cppflags` -std=c++11 -DYYERROR_VERBOSE
LDFLAGS = `$(LLVMCONFIG) --ldflags` -lpthread -ldl -lz -lncurses
LIBS = `$(LLVMCONFIG) --libs`

clean:
	$(RM) -rf parser.cpp parser.hpp parser tokens.cpp $(OBJS)

parser.cpp: parser.y
	bison -d -o $@ $^
	
parser.hpp: parser.cpp

tokens.cpp: tokens.l parser.hpp
	flex -o $@ $^

%.o: %.cpp
	g++ -c $(CPPFLAGS) -o $@ $<


parser: $(OBJS)
	g++ -o $@ $(OBJS) $(LIBS) $(LDFLAGS)

test: parser example.txt
	cat example.txt | ./parser
