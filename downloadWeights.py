from weights_downloader import WeightsDownloader
import custom_node_helpers as helpers
from node import Node
import json
import sys

# basically, just making a portable version of predict.py::predict::load_workflow

# the first goal would be to specify the workflow in an env var, which then gets loaded and stuff installed

# expected in directory: 
# - custom_node_helper.py
# - custom_node_helpers/

weights_downloader = WeightsDownloader()

def apply_helper_methods(method_name, *args, **kwargs):
    # Dynamically applies a method from helpers module with given args.
    # Example usage: self.apply_helper_methods("add_weights", weights_to_download, node)
    for module_name in dir(helpers):
        module = getattr(helpers, module_name)
        method = getattr(module, method_name, None)
        if callable(method):
            method(*args, **kwargs)

def handle_weights(workflow, weights_to_download=None):
    if weights_to_download is None:
        weights_to_download = []

    print("Checking weights")
    embeddings = weights_downloader.get_weights_by_type("EMBEDDINGS")
    embedding_to_fullname = {emb.split(".")[0]: emb for emb in embeddings}
    weights_filetypes = weights_downloader.supported_filetypes

    for node in workflow.values():
        apply_helper_methods("add_weights", weights_to_download, Node(node))

        for input in node["inputs"].values():
            if isinstance(input, str):
                if any(key in input for key in embedding_to_fullname):
                    weights_to_download.extend(
                        embedding_to_fullname[key]
                        for key in embedding_to_fullname
                        if key in input
                    )
                elif any(input.endswith(ft) for ft in weights_filetypes):
                    weights_to_download.append(input)

    weights_to_download = list(set(weights_to_download))

    for weight in weights_to_download:
        weights_downloader.download_weights(weight)

    print("====================================")

# Pass a list of weights names. Choose from list in ./supported_weights.md - Rebase to upstream to get latest list
# example usage: python installFromWorkflow.py workflow.json
if __name__ == "__main__":
    # any number of weights will be passed in as the args
    # collect them in a list
    weightList = sys.argv[1:]
    print("Got weight names:", weightList)
    handle_weights({}, weightList)

# todo: update the provision script to install packages from this repo's cog