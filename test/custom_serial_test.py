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
    for i in range(0x25):
        i = i+0x20
        # Convert the loop counter to a two-character hexadecimal string
        hex_value = int_to_hex_string(i)

        # Create the message
        message = create_message(hex_value)

        # Print the message for debugging purposes
        print(f'Sending: {message}')

        # Send the message over serial
        ser.write(message.encode())

        # Optional: Add a small delay to avoid flooding the serial port
        time.sleep(0.4)

except KeyboardInterrupt:
    print("Stopped by User")

finally:
    # Close the serial port
    ser.close()

# spiBuffer[0]	uint8_t	0x55 (Hex)	
# spiBuffer[1]	uint8_t	0x0 (Hex)	
# spiBuffer[2]	uint8_t	0x23 (Hex)	
# spiBuffer[3]	uint8_t	0x0 (Hex)	
# spiBuffer[4]	uint8_t	0xff (Hex)	
# spiBuffer[5]	uint8_t	0x0 (Hex)	
# spiBuffer[6]	uint8_t	0x0 (Hex)	
# spiBuffer[7]	uint8_t	0xa4 (Hex)	
