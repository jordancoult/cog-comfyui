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

    # In ComfyUI, the data exchanged as IMAGE type is always a 4-dimensional torch.tensor with dimensions (b, h, w, c)
    def find_bounding_box(self, image):
        # Ensure the image tensor is 4-dimensional and has shape (b, h, w, c)
        if image.dim() != 4 or image.shape[0] != 1:
            raise ValueError("Input image must be a 4-dimensional tensor with the first dimension as 1 (b, h, w, c)")

        # Convert to grayscale by averaging the channels, assuming the last dimension is channel
        grayscale = image.mean(dim=-1).squeeze(0)

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
