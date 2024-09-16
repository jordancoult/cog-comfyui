import torch

class ResizeFromKPS:

    def __init__(self):
        pass
    
    @classmethod
    def INPUT_TYPES(s):
        return {
            "required": {
                "image": ("IMAGE",),
                "image_kps_ratio": ("FLOAT", {
                    "default": 0.5,
                    "min": 0.01,
                    "max": 1.0,
                    "step": 0.1,
                    "round": 0.01,
                    "display": "number"
                }),
            },
        }

    RETURN_TYPES = ("BOOL", "INT", "INT", "INT", "INT",)
    RETURN_NAMES = ("found_bbox", "width", "height", "x", "y",)
    FUNCTION = "crop_from_keypoints"

    CATEGORY = "Keypoints Helpers"

    # In ComfyUI, the data exchanged as IMAGE type is always a 4-dimensional torch.tensor with dimensions (b, h, w, c)
    def crop_from_keypoints(self, image, image_kps_ratio):
        # Ensure the image tensor is 4-dimensional and has shape (b, h, w, c)
        if image.dim() != 4:
            raise ValueError("Input image must be a 4-dimensional tensor with shape (b, h, w, c)")

        # Handle batch size > 1, we just process the first image in the batch
        image = image[0]

        # Convert to grayscale by averaging the channels, assuming the last dimension is channel
        grayscale = image[..., :3].mean(dim=-1)

        # Find non-black pixels (values greater than 0)
        non_black_pixels = torch.nonzero(grayscale > 0, as_tuple=False)

        if non_black_pixels.size(0) == 0:
            # If no non-black pixels are found, return zeroed bounding box
            return (False, 0, 0, 0, 0)

        # Get the coordinates of the bounding box
        y_min, x_min = torch.min(non_black_pixels, dim=0).values
        y_max, x_max = torch.max(non_black_pixels, dim=0).values

        # Calculate bbox width and height
        bbox_width = x_max - x_min + 1
        bbox_height = y_max - y_min + 1
        largest_side = max(bbox_width, bbox_height)

        # Calculate new size and crop coordinates from widths
        new_total_width = int(largest_side / image_kps_ratio)
        new_total_height = int(new_total_width * (image.shape[1] / image.shape[2]))

        # Calculate top-left coordinates of new width/height such that the new w/h is centered in the original image
        x = int((image.shape[2] - new_total_width) / 2)
        y = int((image.shape[1] - new_total_height) / 2)

        # Return new crop width, height, x, y
        return (True, new_total_width, new_total_height, x, y)

# Register the node with the necessary mappings
NODE_CLASS_MAPPINGS = {
    "ResizeFromKPS": ResizeFromKPS
}

NODE_DISPLAY_NAME_MAPPINGS = {
    "ResizeFromKPS": "Crop Info from KPS Size"
}
