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
        print(f"Received image shape: {image.shape}")
        print(f"Received image_kps_ratio: {image_kps_ratio}")
        
        # Ensure the image tensor is 4-dimensional and has shape (b, h, w, c)
        if image.dim() != 4:
            raise ValueError("Input image must be a 4-dimensional tensor with shape (b, h, w, c)")

        # Handle batch size > 1, we just process the first image in the batch
        image = image[0]
        print(f"Processing first image in batch, new shape: {image.shape}")

        # Convert to grayscale by averaging the channels, assuming the last dimension is channel
        grayscale = image[..., :3].mean(dim=-1)
        print(f"Grayscale image shape: {grayscale.shape}")

        # Find non-black pixels (values greater than 0)
        non_black_pixels = torch.nonzero(grayscale > 0, as_tuple=False)
        print(f"Number of non-black pixels found: {non_black_pixels.size(0)}")

        if non_black_pixels.size(0) == 0:
            # If no non-black pixels are found, return zeroed bounding box
            print("No non-black pixels found, returning zeroed bounding box.")
            return (False, 0, 0, 0, 0)

        # Get the coordinates of the bounding box
        y_min, x_min = torch.min(non_black_pixels, dim=0).values
        y_max, x_max = torch.max(non_black_pixels, dim=0).values
        print(f"Bounding box - x_min: {x_min}, y_min: {y_min}, x_max: {x_max}, y_max: {y_max}")

        # Calculate bbox width and height
        bbox_width = x_max - x_min + 1
        bbox_height = y_max - y_min + 1
        largest_side = max(bbox_width, bbox_height)
        print(f"BBox width: {bbox_width}, height: {bbox_height}, largest_side: {largest_side}")

        # Calculate new size and crop coordinates from widths
        new_total_width = int(largest_side / image_kps_ratio)
        new_total_height = int(new_total_width * (image.shape[0] / image.shape[1]))
        print(f"New total width: {new_total_width}, New total height: {new_total_height}")

        # Calculate top-left coordinates of new width/height such that the new w/h is centered in the original image
        x = int((image.shape[1] - new_total_width) / 2)
        y = int((image.shape[0] - new_total_height) / 2)
        print(f"Top-left corner coordinates - x: {x}, y: {y}")

        # If x or y are negative then they should both be 0 and width/height should be equal to totals
        if x < 0 or y < 0:
            x = 0
            y = 0
            new_total_width = image.shape[1]
            new_total_height = image.shape[0]
            print(f"Top-left corner coordinates - x: {x}, y: {y}. Resetting width and height to image size so no crop is performed.")
        
        # Return new crop width, height, x, y
        print(f"Returning values - found_bbox: True, width: {new_total_width}, height: {new_total_height}, x: {x}, y: {y}")
        return (True, new_total_width, new_total_height, x, y)

# Register the node with the necessary mappings
NODE_CLASS_MAPPINGS = {
    "ResizeFromKPS": ResizeFromKPS
}

NODE_DISPLAY_NAME_MAPPINGS = {
    "ResizeFromKPS": "Crop Info from KPS Size"
}
