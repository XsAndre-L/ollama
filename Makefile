# top level makefile for Ollama
include make/common-defs.make


# Determine which if any GPU runners we should build
include make/cuda-v11-defs.make
include make/cuda-v12-defs.make
include make/rocm-defs.make

# ifeq ($(CUSTOM_CPU_FLAGS),)
# ifeq ($(ARCH),amd64)
# 	RUNNER_TARGETS=cpu
# endif
# # Without CUSTOM_CPU_FLAGS we default to build both v11 and v12 if present
# ifeq ($(OLLAMA_SKIP_CUDA_GENERATE),)
# ifneq ($(CUDA_11_COMPILER),)
# 	RUNNER_TARGETS += cuda_v11
# endif
# ifneq ($(CUDA_12_COMPILER),)
# 	RUNNER_TARGETS += cuda_v12
# endif
# endif
# else # CUSTOM_CPU_FLAGS is set, we'll build only the latest cuda version detected
# ifneq ($(CUDA_12_COMPILER),)
# 	RUNNER_TARGETS += cuda_v12
# else ifneq ($(CUDA_11_COMPILER),)
# 	RUNNER_TARGETS += cuda_v11
# endif
# endif

# ifeq ($(OLLAMA_SKIP_ROCM_GENERATE),)
# ifneq ($(HIP_COMPILER),)
# 	RUNNER_TARGETS += rocm
# endif
# endif

# Initialize RUNNER_TARGETS
RUNNER_TARGETS :=

export CUDA_12_COMPILER=/usr/local/cuda-12/bin/nvcc


# Determine CPU runner
ifeq ($(CUSTOM_CPU_FLAGS),)
    ifeq ($(ARCH),amd64)
        RUNNER_TARGETS += cpu
    endif
endif

# Determine CUDA runners
ifeq ($(OLLAMA_SKIP_CUDA_GENERATE),)
    ifneq ($(CUSTOM_CPU_FLAGS),)
        # CUSTOM_CPU_FLAGS is set: build only the latest CUDA version available
        ifneq ($(CUDA_12_COMPILER),)
            RUNNER_TARGETS += cuda_v12
        else ifneq ($(CUDA_11_COMPILER),)
            RUNNER_TARGETS += cuda_v11
        endif
    else
        # CUSTOM_CPU_FLAGS is not set: build all available CUDA versions
        ifneq ($(CUDA_11_COMPILER),)
            RUNNER_TARGETS += cuda_v11
        endif
        ifneq ($(CUDA_12_COMPILER),)
            RUNNER_TARGETS += cuda_v12
        endif
    endif
endif

# Determine ROCm runner
ifeq ($(OLLAMA_SKIP_ROCM_GENERATE),)
    ifneq ($(HIP_COMPILER),)
        RUNNER_TARGETS += rocm
    endif
endif

# Print resolved RUNNER_TARGETS for debugging
@echo "RUNNER_TARGETS: $(RUNNER_TARGETS)"	
### ONLY CPU?? IMPORTANT
# RUNNER_TARGETS := cpu



# Debugging: Uncomment the following line to see the RUNNER_TARGETS
# $(info RUNNER_TARGETS=$(RUNNER_TARGETS))



# all: runners exe

# dist: $(addprefix dist_, $(RUNNER_TARGETS)) dist_exe

# dist_%:
# 	@$(MAKE) --no-print-directory -f make/Makefile.$* dist

# runners: $(RUNNER_TARGETS)

# $(RUNNER_TARGETS):
# 	@$(MAKE) --no-print-directory -f make/Makefile.$@

# exe dist_exe:
# 	@$(MAKE) --no-print-directory -f make/Makefile.ollama $@

# help-sync apply-patches create-patches sync sync-clean:
# 	@$(MAKE) --no-print-directory -f make/Makefile.sync $@

# test integration lint:
# 	@$(MAKE) --no-print-directory -f make/Makefile.test $@

# clean:
# 	rm -rf $(BUILD_DIR) $(DIST_LIB_DIR) $(OLLAMA_EXE) $(DIST_OLLAMA_EXE)
# 	go clean -cache

# help:
# 	@echo "The following make targets will help you build Ollama"
# 	@echo ""
# 	@echo "	make all   		# (default target) Build Ollama llm subprocess runners, and the primary ollama executable"
# 	@echo "	make runners		# Build Ollama llm subprocess runners; after you may use 'go build .' to build the primary ollama exectuable"
# 	@echo "	make <runner>		# Build specific runners. Enabled: '$(RUNNER_TARGETS)'"
# 	@echo "	make dist		# Build the runners and primary ollama executable for distribution"
# 	@echo "	make help-sync 		# Help information on vendor update targets"
# 	@echo "	make help-runners 	# Help information on runner targets"
# 	@echo ""
# 	@echo "The following make targets will help you test Ollama"
# 	@echo ""
# 	@echo "	make test   		# Run unit tests"
# 	@echo "	make integration	# Run integration tests.  You must 'make all' first"
# 	@echo "	make lint   		# Run lint and style tests"
# 	@echo ""
# 	@echo "For more information see 'docs/development.md'"
# 	@echo ""


# help-runners:
# 	@echo "The following runners will be built based on discovered GPU libraries: '$(RUNNER_TARGETS)'"
# 	@echo ""
# 	@echo "GPU Runner CPU Flags: '$(GPU_RUNNER_CPU_FLAGS)'  (Override with CUSTOM_CPU_FLAGS)"
# 	@echo ""
# 	@echo "# CUDA_PATH sets the location where CUDA toolkits are present"
# 	@echo "CUDA_PATH=$(CUDA_PATH)"
# 	@echo "	CUDA_11_PATH=$(CUDA_11_PATH)"
# 	@echo "	CUDA_11_COMPILER=$(CUDA_11_COMPILER)"
# 	@echo "	CUDA_12_PATH=$(CUDA_12_PATH)"
# 	@echo "	CUDA_12_COMPILER=$(CUDA_12_COMPILER)"
# 	@echo ""
# 	@echo "# HIP_PATH sets the location where the ROCm toolkit is present"
# 	@echo "HIP_PATH=$(HIP_PATH)"
# 	@echo "	HIP_COMPILER=$(HIP_COMPILER)"

# .PHONY: all exe dist help help-sync help-runners test integration lint runners clean $(RUNNER_TARGETS)

MAKE_FLAGS_COMMON  = --no-print-directory -f
MAKEFILE_RUNNER    = make/Makefile.$@
MAKEFILE_DIST      = make/Makefile.$*
MAKEFILE_OLLAMA    = make/Makefile.ollama
MAKEFILE_SYNC      = make/Makefile.sync
MAKEFILE_TEST      = make/Makefile.test


# Define the default target
all: runners exe

# Define the distribution target
dist: $(addprefix dist_, $(RUNNER_TARGETS)) dist_exe

# Pattern rule for dist_<target>
dist_%:
	@$(MAKE) $(MAKE_FLAGS_COMMON) $(MAKEFILE_DIST) dist

# Target to build all runners
runners: $(RUNNER_TARGETS)

# Pattern rule for each runner
$(RUNNER_TARGETS):
	@$(MAKE) $(MAKE_FLAGS_COMMON) $(MAKEFILE_RUNNER)

# Targets for building executables
exe dist_exe:
	@$(MAKE) $(MAKE_FLAGS_COMMON) $(MAKEFILE_OLLAMA) $@

# Sync-related targets
help-sync apply-patches create-patches sync sync-clean:
	@$(MAKE) $(MAKE_FLAGS_COMMON) $(MAKEFILE_SYNC) $@

# Test-related targets
test integration lint:
	@$(MAKE) $(MAKE_FLAGS_COMMON) $(MAKEFILE_TEST) $@

# Clean target
clean:
	rm -rf $(BUILD_DIR) $(DIST_LIB_DIR) $(OLLAMA_EXE) $(DIST_OLLAMA_EXE)
	go clean -cache

# Help targets
help:
	@echo "The following make targets will help you build Ollama"
	@echo ""
	@echo "	make all   		# (default target) Build Ollama llm subprocess runners, and the primary ollama executable"
	@echo "	make runners		# Build Ollama llm subprocess runners; after you may use 'go build .' to build the primary ollama executable"
	@echo "	make <runner>		# Build specific runners. Enabled: '$(RUNNER_TARGETS)'"
	@echo "	make dist		# Build the runners and primary ollama executable for distribution"
	@echo "	make help-sync 		# Help information on vendor update targets"
	@echo "	make help-runners 	# Help information on runner targets"
	@echo ""
	@echo "The following make targets will help you test Ollama"
	@echo ""
	@echo "	make test   		# Run unit tests"
	@echo "	make integration	# Run integration tests.  You must 'make all' first"
	@echo "	make lint   		# Run lint and style tests"
	@echo ""
	@echo "For more information see 'docs/development.md'"
	@echo ""

help-runners:
	@echo "The following runners will be built based on discovered GPU libraries: '$(RUNNER_TARGETS)'"
	@echo ""
	@echo "GPU Runner CPU Flags: '$(GPU_RUNNER_CPU_FLAGS)'  (Override with CUSTOM_CPU_FLAGS)"
	@echo ""
	@echo "# CUDA_PATH sets the location where CUDA toolkits are present"
	@echo "CUDA_PATH=$(CUDA_PATH)"
	@echo "	CUDA_11_PATH=$(CUDA_11_PATH)"
	@echo "	CUDA_11_COMPILER=$(CUDA_11_COMPILER)"
	@echo "	CUDA_12_PATH=$(CUDA_12_PATH)"
	@echo "	CUDA_12_COMPILER=$(CUDA_12_COMPILER)"
	@echo ""
	@echo "# HIP_PATH sets the location where the ROCm toolkit is present"
	@echo "HIP_PATH=$(HIP_PATH)"
	@echo "	HIP_COMPILER=$(HIP_COMPILER)"

# Handy debugging for Make variables
print-%:
	@echo '$*=$($*)'

# Phony targets to prevent conflicts with files of the same name
.PHONY: all exe dist help help-sync help-runners test integration lint runners clean $(RUNNER_TARGETS) dist_%


# Handy debugging for make variables
print-%:
	@echo '$*=$($*)'
