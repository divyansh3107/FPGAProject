import serial

# Open UART communication (adjust COM port and baud rate as needed)
ser = serial.Serial('/dev/ttyUSB1', 115200)  # Replace with your actual COM port

# Open the image file
with open('output_image.raw', 'rb') as image_file:
    # Read the image data in chunks and send it over UART
    while (chunk := image_file.read(1024)):  # Read in 1 KB chunks
        ser.write(chunk)

# Close the UART connection
ser.close()
print("Sent")
