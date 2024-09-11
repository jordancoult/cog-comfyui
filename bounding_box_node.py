import torch

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
        # Assuming 'image' is a PyTorch tensor with shape (C, H, W)
        if image.dim() != 3:
            raise ValueError("Input image must have 3 dimensions (C, H, W)")

        # Convert to grayscale by summing the channels
        grayscale = torch.sum(image, dim=0)

        # Find non-black pixels (values greater than 0)
        non_black_pixels = torch.nonzero(grayscale > 0, as_tuple=False)

        if non_black_pixels.size(0) == 0:
            # If no non-black pixels are found, return zeroed bounding box
            return (0, 0, 0, 0)

        # Get the coordinates of the bounding box
        y_min, x_min = torch.min(non_black_pixels, dim=0).values
        y_max, x_max = torch.max(non_black_pixels, dim=0).values

        # Calculate width and height
        width = x_max - x_min + 1
        height = y_max - y_min + 1

        # Return width, height, and top-left corner (x_min, y_min)
        return (width.item(), height.item(), x_min.item(), y_min.item())

# Register the node with the necessary mappings
NODE_CLASS_MAPPINGS = {
    "BoundingBox": BoundingBox
}

NODE_DISPLAY_NAME_MAPPINGS = {
    "BoundingBox": "Bounding Box Finder"
}
