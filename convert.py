from PIL import Image
import cv2
import time

# Initialize the webcam
cap = cv2.VideoCapture(0)

# Check if the webcam is opened correctly
if not cap.isOpened():
    print("Error: Could not open webcam.")
else:
    # Wait for 3 seconds to capture the image
    time.sleep(3)

    # Capture frame from the webcam
    ret, frame = cap.read()

    # Check if the frame was captured
    if ret:
        # Save the captured image
        cv2.imwrite("hi.jpeg", frame)
        print("Image captured and saved as hi.jpeg.")
    else:
        print("Error: Could not capture image.")

    # Release the webcam
    cap.release()
    cv2.destroyAllWindows()

# Function to convert an image to 12-bit COE format
def convert_image_to_coe(image_path, coe_output, width=None, height=None):
    # Open the image
    image = Image.open(image_path).convert('RGB')
    
    # Resize the image if width and height are specified
    if width and height:
        image = image.resize((width, height))

    # Create the COE file
    with open(coe_output, 'w') as coe_file:
        # Write COE header
        coe_file.write('memory_initialization_radix=16;\n')
        coe_file.write('memory_initialization_vector=\n')

        # Process image pixels
        for y in range(image.height):
            for x in range(image.width):
                # Get the RGB values for the pixel
                r, g, b = image.getpixel((x, y))
                
                # Convert each channel to 4-bit (0-15)
                r_4bit = r >> 4  # Right shift by 4 to get 4 most significant bits
                g_4bit = g >> 4
                b_4bit = b >> 4

                # Combine the 4-bit values into 12-bit RGB (4 bits for each channel)
                rgb_12bit = (r_4bit << 8) | (g_4bit << 4) | b_4bit

                # Write the 12-bit RGB value as hexadecimal
                coe_file.write(f'{rgb_12bit:03X},\n')

        # Terminate the COE file with a semicolon
        coe_file.write(';\n')

    print(f"Image converted to {coe_output} in 12-bit RGB format.")

# Usage
image_path = 'hi.jpeg'  # Input JPEG image
coe_output = 'image_output.coe'  # Output COE file
image_width = 256  # Desired image width
image_height = 256  # Desired image height

# Convert image to COE
convert_image_to_coe(image_path, coe_output, width=image_width, height=image_height)
