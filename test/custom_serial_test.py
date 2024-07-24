import serial
import time

# Function to convert an integer to a two-character hexadecimal string
def int_to_hex_string(i):
    return f'{i:02x}'

# Function to create the message
def create_message(value):
    return f'$00.00.ff.00.00.00.{value}.a4#'

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


# Configure the serial port (update 'COM3' to your port)
ser = serial.Serial('COM5', 115200, timeout=1)

try:
    for j in range(4):
        for i in range(0xff):
                
            # Convert the loop counter to a two-character hexadecimal string
            hex_value = int_to_hex_string(i)

            # Create the message
            if j == 0:
                message = create_messageA(hex_value)
            elif j == 1:
                message = create_messageB(hex_value)
            elif j == 2:
                message = create_messageC(hex_value)
            elif j == 3:
                message = create_messageD(hex_value)
                
            # Print the message for debugging purposes
            print(f'Sending: {message}')

            # Send the message over serial
            ser.write(message.encode())

            # Optional: Add a small delay to avoid flooding the serial port
            #time.sleep(0.01)





except KeyboardInterrupt:
    print("Stopped by User")

finally:
    # Close the serial port
    ser.close()
