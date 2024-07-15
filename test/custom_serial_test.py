import serial
import time

# Function to convert an integer to a two-character hexadecimal string
def int_to_hex_string(i):
    return f'{i:02x}'

# Function to create the message
def create_message(value):
    return f'$00.00.ff.00.00.00.{value}.a4#'

# Configure the serial port (update 'COM3' to your port)
ser = serial.Serial('COM5', 115200, timeout=1)

try:
    for i in range((0xff-0xd8)):
        j = i+(0xd8)
        # Convert the loop counter to a two-character hexadecimal string
        hex_value = int_to_hex_string(j)

        # Create the message
        message = create_message(hex_value)

        # Print the message for debugging purposes
        print(f'Sending: {message}')

        # Send the message over serial
        ser.write(message.encode())

        # Optional: Add a small delay to avoid flooding the serial port
        time.sleep(0.1)

except KeyboardInterrupt:
    print("Stopped by User")

finally:
    # Close the serial port
    ser.close()
