import numpy as np

class BoundingBox:

    def __init__(self):
        pass
    
    @classmethod
    def INPUT_TYPES(s):
        return {
            "required": {
                "image": ("IMAGE",),
            },
        }

    RETURN_TYPES = ("INT", "INT", "INT", "INT",)
    RETURN_NAMES = ("width", "height", "x", "y",)
    FUNCTION = "find_bounding_box"

    CATEGORY = "Image Processing"

    def find_bounding_box(self, image):
        # Assuming 'image' is a NumPy array with shape (H, W, C)
        # where H is the height, W is the width, and C is the number of channels
        
        # Convert to grayscale to make processing easier
        grayscale = np.sum(image, axis=2)
        
        # Find non-black pixels (non-zero in grayscale)
        non_black_pixels = np.argwhere(grayscale > 0)
        
        if len(non_black_pixels) == 0:
            # If no non-black pixels are found, return zeroed bounding box
            return (0, 0, 0, 0)
        
        # Get the coordinates of the bounding box
        y_min, x_min = np.min(non_black_pixels, axis=0)
        y_max, x_max = np.max(non_black_pixels, axis=0)

        # Calculate width and height
        width = x_max - x_min + 1
        height = y_max - y_min + 1

        # Return width, height, and top-left corner (x_min, y_min)
        return (width, height, x_min, y_min)


# Register the node with the necessary mappings
NODE_CLASS_MAPPINGS = {
    "BoundingBox": BoundingBox
}

NODE_DISPLAY_NAME_MAPPINGS = {
    "BoundingBox": "Bounding Box Finder"
}
