################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (11.3.rel1)
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include Drivers/STM32L4xx_HAL_Driver/Src/subdir.mk
-include Core/Startup/subdir.mk
-include Core/Src/subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_DEPS)),)
-include $(S_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

OPTIONAL_TOOL_DEPS := \
$(wildcard ../makefile.defs) \
$(wildcard ../makefile.init) \
$(wildcard ../makefile.targets) \


BUILD_ARTIFACT_NAME := ice40_rgbw_lamp_controller_bl475
BUILD_ARTIFACT_EXTENSION := elf
BUILD_ARTIFACT_PREFIX :=
BUILD_ARTIFACT := $(BUILD_ARTIFACT_PREFIX)$(BUILD_ARTIFACT_NAME)$(if $(BUILD_ARTIFACT_EXTENSION),.$(BUILD_ARTIFACT_EXTENSION),)

# Add inputs and outputs from these tool invocations to the build variables 
EXECUTABLES += \
ice40_rgbw_lamp_controller_bl475.elf \

MAP_FILES += \
ice40_rgbw_lamp_controller_bl475.map \

SIZE_OUTPUT += \
default.size.stdout \

OBJDUMP_LIST += \
ice40_rgbw_lamp_controller_bl475.list \


# All Target
all: main-build

# Main-build Target
main-build: ice40_rgbw_lamp_controller_bl475.elf secondary-outputs

# Tool invocations
ice40_rgbw_lamp_controller_bl475.elf ice40_rgbw_lamp_controller_bl475.map: $(OBJS) $(USER_OBJS) C:\Users\Enrico\Documents\GitHub\tt08-rgbw-controller\test\stm32\ice40_rgbw_lamp_controller_bl475\STM32L475VGTX_FLASH.ld makefile objects.list $(OPTIONAL_TOOL_DEPS)
	arm-none-eabi-gcc -o "ice40_rgbw_lamp_controller_bl475.elf" @"objects.list" $(USER_OBJS) $(LIBS) -mcpu=cortex-m4 -T"C:\Users\Enrico\Documents\GitHub\tt08-rgbw-controller\test\stm32\ice40_rgbw_lamp_controller_bl475\STM32L475VGTX_FLASH.ld" --specs=nosys.specs -Wl,-Map="ice40_rgbw_lamp_controller_bl475.map" -Wl,--gc-sections -static --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -Wl,--start-group -lc -lm -Wl,--end-group
	@echo 'Finished building target: $@'
	@echo ' '

default.size.stdout: $(EXECUTABLES) makefile objects.list $(OPTIONAL_TOOL_DEPS)
	arm-none-eabi-size  $(EXECUTABLES)
	@echo 'Finished building: $@'
	@echo ' '

ice40_rgbw_lamp_controller_bl475.list: $(EXECUTABLES) makefile objects.list $(OPTIONAL_TOOL_DEPS)
	arm-none-eabi-objdump -h -S $(EXECUTABLES) > "ice40_rgbw_lamp_controller_bl475.list"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) default.size.stdout ice40_rgbw_lamp_controller_bl475.elf ice40_rgbw_lamp_controller_bl475.list ice40_rgbw_lamp_controller_bl475.map
	-@echo ' '

secondary-outputs: $(SIZE_OUTPUT) $(OBJDUMP_LIST)

fail-specified-linker-script-missing:
	@echo 'Error: Cannot find the specified linker script. Check the linker settings in the build configuration.'
	@exit 2

warn-no-linker-script-specified:
	@echo 'Warning: No linker script specified. Check the linker settings in the build configuration.'

.PHONY: all clean dependents main-build fail-specified-linker-script-missing warn-no-linker-script-specified

-include ../makefile.targets
