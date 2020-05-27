CC=g++

CFLAGS= -O2
SQLFLAGS= `mysql_config --cflags --libs`

# Comment this line to disable address check on login,
# if you use the auto exchange feature...
#CFLAGS=-c -O2 -I /usr/include/mysql
LDFLAGS=-O2 `mysql_config --libs`

LDLIBS=iniparser/libiniparser.a algos/libalgos.a sha3/libhash.a -lpthread -lgmp -lm -lstdc++
LDLIBS+=-lmysqlclient

SOURCES=stratum.cpp db.cpp coind.cpp coind_aux.cpp coind_template.cpp coind_submit.cpp util.cpp list.cpp \
	rpc.cpp job.cpp job_send.cpp job_core.cpp merkle.cpp share.cpp socket.cpp coinbase.cpp \
	client.cpp client_submit.cpp client_core.cpp client_difficulty.cpp remote.cpp remote_template.cpp \
	user.cpp object.cpp json.cpp base58.cpp uint256.cpp

SOURCES+= randomx.cpp RandomX/src/aes_hash.cpp RandomX/src/argon2_ref.c RandomX/src/argon2_ssse3.c RandomX/src/argon2_avx2.c                 \
	RandomX/src/bytecode_machine.cpp RandomX/src/cpu.cpp RandomX/src/dataset.cpp RandomX/src/soft_aes.cpp RandomX/src/virtual_memory.cpp \
	RandomX/src/vm_interpreted.cpp RandomX/src/allocator.cpp RandomX/src/assembly_generator_x86.cpp RandomX/src/instruction.cpp          \
	RandomX/src/randomx.cpp RandomX/src/superscalar.cpp RandomX/src/vm_compiled.cpp RandomX/src/vm_interpreted_light.cpp                 \
	RandomX/src/argon2_core.c RandomX/src/blake2_generator.cpp RandomX/src/instructions_portable.cpp RandomX/src/reciprocal.c            \
	RandomX/src/virtual_machine.cpp RandomX/src/vm_compiled_light.cpp RandomX/src/blake2/blake2b.c RandomX/src/jit_compiler_x86.cpp      \
	RandomX/src/jit_compiler_x86_static.S rxmonero/rx-slow-hash.c

CFLAGS += -DHAVE_CURL
SOURCES += rpc_curl.cpp
LDCURL = $(shell /usr/bin/pkg-config --static --libs libcurl)
LDFLAGS += $(LDCURL)

OBJECTS=$(SOURCES:.cpp=.o)
OUTPUT=stratum

CODEDIR1=algos
CODEDIR2=sha3
CODEDIR3=iniparser

.PHONY: projectcode1 projectcode2 projectcode3

all: projectcode1 projectcode2 projectcode3 $(SOURCES) $(OUTPUT)

projectcode1:
	$(MAKE) -C $(CODEDIR1)

projectcode2:
	$(MAKE) -C $(CODEDIR2)

projectcode3:
	$(MAKE) -C $(CODEDIR3)

$(SOURCES): stratum.h util.h

$(OUTPUT): $(OBJECTS)
	$(CC) $(OBJECTS) $(LDLIBS) $(LDFLAGS) -o $@

.cpp.o:
	$(CC) $(CFLAGS) $(SQLFLAGS) -c $< -o $@

.c.o:
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f *.o
	rm -f algos/*.o
	rm -f algos/*.a
	rm -f sha3/*.o
	rm -f sha3/*.a
	rm -f algos/ar2/*.o
	rm -f RandomX/src/*.o

install: clean all
	strip -s stratum
	cp stratum /usr/local/bin/
	cp stratum ../bin/

