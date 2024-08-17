import serial
import time
import keyboard




# Function to create the message with dynamic parameters
def create_message(params):
    return f"${params[0]}.{params[1]}.{params[2]}.{params[3]}.{params[4]}.{params[5]}.{params[6]}.{params[7]}#\n"

# Function to update a specific parameter
def update_parameter(params, index, value):
    params[index] = value

# Function to convert an integer to a two-character hexadecimal string
def int_to_hex_string(i):
    return f'{i:02x}'

# Function to create the message
def create_messageA(value):
    return f'$00.{value}.00.00.00.00.00.21#'

# Function to create the message
def create_messageB(value):
    return f'$00.00.{value}.00.00.00.00.21#'

# Function to create the message
def create_messageC(value):
    return f'$00.00.00.{value}.00.00.00.21#'

# Function to create the message
def create_messageD(value):
    return f'$00.00.00.00.{value}.00.00.21#'

# Function to create the message
def create_messageInt(value):
    return f'$00.00.00.00.00.{value}.00.21#'

# Function to create the message
def create_messageColorWheel(value):
    return f'$00.00.ff.00.00.00.{value}.a4#'

# Configure the serial port (update 'COM3' to your port)
ser = serial.Serial('COM5', 115200, timeout=5)


try:
    print(f'Next test: single color control.')
    keyboard.wait('y')
    # Initial parameters
    params = ["00", "00", "00", "00", "00", "00", "00", "21"]
    
    for j in range(5):
        if (j == 4):
            params = ["00", "00", "00", "00", "00", "00", "00", "21"] # reset to make a new test, with the luminosity
        for i in range(0xff):
                
            # Convert the loop counter to a two-character hexadecimal string
            hex_value = int_to_hex_string(i)

            # Create the message
            if j == 0:
                update_parameter(params, 1, hex_value)
                message = create_message(params)
            elif j == 1:
                update_parameter(params, 2, hex_value)
                message = create_message(params)                
            elif j == 2:
                update_parameter(params, 3, hex_value)
                message = create_message(params)                
            elif j == 3:
                update_parameter(params, 4, hex_value)
                message = create_message(params)
            elif j == 4:
                update_parameter(params, 4, int_to_hex_string(0x35))
                update_parameter(params, 3, int_to_hex_string(0x94))
                update_parameter(params, 5, hex_value) # luminosity test with a random color, in single color mode. Nothing should happen
                message = create_message(params)

            # Print the message for debugging purposes
            print(f'Sending: {message}')

            # Send the message over serial
            ser.write(message.encode())

            # Optional: Add a small delay to avoid flooding the serial port
            #time.sleep(0.01)

    print("Press 'y' to continue. Next test: color wheel")
    keyboard.wait('y')
    params = ["00", "00", "00", "00", "00", "ff", "00", "a4"]
    create_message(params)
    i = 0
    for i in range(0xff):
        # Convert the loop counter to a two-character hexadecimal string
        hex_value = int_to_hex_string(i)
        update_parameter(params, 6, hex_value)
        message = create_message(params)
        # Send the message over serial
        print(f'Sending: {message}')
        ser.write(message.encode())
        time.sleep(0.1)

    print("Press 'y' to continue. Next test: white with random color 1")
    keyboard.wait('y')
    params = ["00", "00", "00", "00", "00", "ff", "00", "a4"]
    create_message(params)
    i = 0
    update_parameter(params, 6, int_to_hex_string(0xa0))
    message = create_message(params)
    ser.write(message.encode())
    keyboard.wait('y')
    for i in range(0xff):      
        # Convert the loop counter to a two-character hexadecimal string
        update_parameter(params, 4, int_to_hex_string(i))
        print(f'Color wheel. Sending W: {message}')
        #update_parameter(params, 6, int_to_hex_string(0xaf))
        message = create_message(params)
        ser.write(message.encode())
        

    print("Press 'y' to continue. Next test: white with random color 2")
    keyboard.wait('y')
    params = ["00", "00", "00", "00", "00", "ff", "00", "a4"]
    create_message(params)
    i = 0
    update_parameter(params, 6, int_to_hex_string(0xf0))
    message = create_message(params)
    ser.write(message.encode())
    keyboard.wait('y')
    for i in range(0xff):      
        # Convert the loop counter to a two-character hexadecimal string
        update_parameter(params, 4, int_to_hex_string(i))
        print(f'Color wheel. Sending W: {message}')
        update_parameter(params, 6, int_to_hex_string(0xf0))
        message = create_message(params)
        ser.write(message.encode())
    for i in range(0xff):      
        # Convert the loop counter to a two-character hexadecimal string
        update_parameter(params, 4, int_to_hex_string(0xff-i))
        print(f'Color wheel. Sending W: {message}')
        update_parameter(params, 6, int_to_hex_string(0xf0))
        message = create_message(params)
        ser.write(message.encode())
        
    print("Press 'y' to continue. Next test: intensity with random color 2")
    keyboard.wait('y')
    for i in range(0xff):      
        # Convert the loop counter to a two-character hexadecimal string
        print(f'Color wheel. Sending intensity to previous color: {message}')
        update_parameter(params, 4, int_to_hex_string(0x0))
        update_parameter(params, 5, int_to_hex_string(i+1))
        message = create_message(params)
        ser.write(message.encode())

except KeyboardInterrupt:
    print("Test program terminated.")

finally:
    # Close the serial port
    ser.close()
